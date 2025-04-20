const axios = require("axios");
const xml2js = require("xml2js");
// import reverse from "latlng-to-iso3166";  // Backup fallback if needed
// import { featureCollection, point } from "@turf/helpers";
const { supabase } = require('../utils/supabaseClient');


const USER_COUNTRY = "India"; // Update based on your logic
const USER_STATE = "Maharashtra"; // Update based on your logic

const determineSeverity = (alertLevel) => {
  switch ((alertLevel || "").toLowerCase()) {
    case "green": return "Low";
    case "orange": return "Moderate";
    case "red": return "High";
    default: return "Moderate";
  }
};

const determineType = (eventTypeCode) => {
  const map = {
    EQ: "Earthquake",
    TC: "Cyclone",
    FL: "Flood",
    VO: "Volcano",
    WF: "Wildfire",
    DR: "Drought",
    TS: "Tsunami",
    LS: "Landslide",
  };
  return map[eventTypeCode?.toUpperCase()] || "Other";
};

async function reverseGeocode(lat, lng) {
  try {
    const { data } = await axios.get(
      `https://nominatim.openstreetmap.org/reverse?format=json&lat=${lat}&lon=${lng}&zoom=10&addressdetails=1`
    );
    const { country, state } = data.address || {};
    return { country, state };
  } catch (err) {
    console.error("Reverse geocode error:", err.message);
    return {};
  }
}

async function fetchAndProcessGDACS() {
  console.log("🌐 Fetching GDACS feed...");
  const feedUrl = "https://www.gdacs.org/xml/rss.xml";

  try {
    const response = await axios.get(feedUrl);
    const result = await xml2js.parseStringPromise(response.data);

    console.log("✅ XML fetched and parsed");

    const items = result?.rss?.channel?.[0]?.item || [];
    console.log("📝 Total items in feed:", items.length);

    for (const item of items) {
      // console.log("🧾 Item keys:", Object.keys(item));
      const title = item.title?.[0];
      const link = item.link?.[0];
      const pubDate = item.pubDate?.[0];

      let location = item["geo:Point"]?.[0];
      const lat = parseFloat(location['geo:lat']?.[0]);
      const lng = parseFloat(location['geo:long']?.[0]);

      const alertLevel = item["gdacs:alertlevel"]?.[0];
      const eventTypeCode = item["gdacs:eventtype"]?.[0];

      if (!lat || !lng || !title) continue;

      console.log("Determining severity");

      const severity = determineSeverity(alertLevel);
      const type = determineType(eventTypeCode);

      console.log("Severity: ", severity, " Type: ", type);

      location = `POINT(${lng} ${lat})`;
      // console.log("Location: ", location);


      // console.log("� Parsed Danger Zone:");
      // console.log({ title, location, pubDate, type, severity });

      // Reverse Geocode
      const { country, state } = await reverseGeocode(lat, lng);

      if (!country || !state) continue;

      const countryMatch = country.toLowerCase() === USER_COUNTRY.toLowerCase();
      const stateMatch = state.toLowerCase() === USER_STATE.toLowerCase();

      // console.log("� Parsed Danger Zone:");
      // console.log({ title, location, pubDate, type, severity,country, state});

      if (!countryMatch && !stateMatch) {
        console.log("⚠️ Skipped: Not in user region");
        continue;
      }


      // Check for duplicate
      const { data: existing, error: findErr } = await supabase
        .from("danger_zones")
        .select("*")
        .eq("name", title)
        .eq("location", location)
        .maybeSingle();

      if (findErr) {
        console.error("❌ Supabase find error:", findErr.message);
        continue;
      }

      if (existing) {
        console.log("✅ Already exists. Skipping.");
        continue;
      }

      const { error: insertErr } = await supabase.from("danger_zones").insert([
        {
          name: title,
          category: type,
          type: "Natual Dissater",
          severity: severity,
          location: location,
          country: country,
          state: state,
          updated_at: new Date(pubDate).toISOString(),
        },
      ]);

      if (insertErr) {
        console.error("❌ Insert error:", insertErr.message);
      } else {
        console.log("✅ Inserted:", title);
      }
    }
  } catch (error) {
    console.error("🚨 Failed to fetch or process GDACS feed:", error.message);
  }
}

// module.exports = fetchAndProcessGDACS;
fetchAndProcessGDACS();
