const axios = require("axios");
const { supabase } = require("../utils/supabaseClient");

const USER_COUNTRY = "India";
const USER_STATE = "Maharashtra";

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

async function fetchOpenWeatherAlerts() {
  console.log("🌤 Fetching OpenWeatherMap alerts...");

  const API_KEY = process.env.OPENWEATHER_API_KEY;
  const LAT = 19.076; // Mumbai center
  const LON = 72.8777;

  try {
    const response = await axios.get(
      `https://api.openweathermap.org/data/2.5/onecall?lat=${LAT}&lon=${LON}&exclude=current,minutely,hourly,daily&appid=${API_KEY}`
    );

    const alerts = response.data.alerts || [];
    console.log("📝 Total weather alerts:", alerts.length);

    for (const alert of alerts) {
      const { event, description, start } = alert;

      const lat = LAT;
      const lng = LON;
      const location = `POINT(${lng} ${lat})`;
      const category = "Weather Alert";

      // const severity = "Moderate"; // Or extract from event text if available
      const fullText = `${event} ${description}`.toLowerCase();

      let severity = "Moderate"; // Default

      if (/storm|cyclone|flood|heatwave|tsunami|hurricane|typhoon/.test(fullText)) {
         severity = "High";
      } 
      else if (/heavy rain|snow|fog|hail|winds|wind/.test(fullText)) {
        severity = "Moderate";
      }
      else if (/drizzle|light rain|clouds|mist|breeze/.test(fullText)) {
        severity = "Low";
      }

      const { country, state } = await reverseGeocode(lat, lng);

      if (!country || !state) continue;

      const countryMatch = country.toLowerCase() === USER_COUNTRY.toLowerCase();
      const stateMatch = state.toLowerCase() === USER_STATE.toLowerCase();

      if (!countryMatch && !stateMatch) {
        console.log("⚠️ Skipped: Not in user region");
        continue;
      }

      console.log({ event, location, severity, category });

      // Check for duplicate
      const { data: existing, error: findErr } = await supabase
        .from("danger_zones")
        .select("*")
        .eq("name", event)
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
          name: event,
          category,
          type: description,
          severity,
          location,
          country,
          state,
          source: "OpenWeatherMap",
          updated_at: new Date(start * 1000).toISOString(),
        },
      ]);

      if (insertErr) {
        console.error("❌ Insert error:", insertErr.message);
      } else {
        console.log("✅ Inserted weather alert:", event);
      }
    }
  } catch (err) {
    console.error("🌩 OpenWeather fetch error:", err.message);
  }
}

// module.exports = fetchOpenWeatherAlerts;

fetchOpenWeatherAlerts();
