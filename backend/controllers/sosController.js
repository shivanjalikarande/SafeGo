const axios = require('axios');
const { supabase } = require('../utils/supabaseClient');
const { getUserLocationFromDB } = require('../utils/getUserLocationFromDB');
// const { sendAlertToService } = require('../utils/sendAlertToService');

// const GOOGLE_API_KEY = process.env.GOOGLE_API_KEY;

const addSOSHistory = async (req, res) => {
    console.log("In sos history add backend");

    const { user_id, location, reason, address, severity} = req.body;

    try {
        const { data, error } = await supabase
        .from('sos_history')
        .insert([{ user_id, location, reason, address, severity}])
        .select();

        if (error) {
            console.error("Supabase insert error:", error);
            return res.status(400).json({ error });
        }

        console.log('Adding SOS history');
        res.status(201).json({ data });
    } catch (err) {
        console.error("Unexpected server error:", err);
        res.status(500).json({ error: err.message });
    }
};

const getSOSHistory = async (req, res) => {
    console.log("Fetching user SOS history...");

    const { userId } = req.params;

    try {
        const { data, error } = await supabase
            .from('sos_history')
            .select('*')
            .eq('user_id', userId)
            .order('timestamp', { ascending: false });

        if (error) return res.status(400).json({ error });
        console.log("User SOS history suceessfully fetched");
        res.status(200).json({ data });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};


// const CATEGORY_MAP = {
//     Police: 'police',
//     Ambulance: 'hospital',
//     Fire: 'fire_station',
// };

// const triggerSOS = async (req, res) => {
//     console.log("Call to emergency services in backend");
//     try {
//         const { user_id, type } = req.body;

//         if (!user_id || !type) {
//             return res.status(400).json({ error: 'Missing parameters' });
//         }

//         // Step 1: Get user location
//         // const { latitude, longitude } = await getUserLocationFromDB(user_id);

//         const latitude = 19.0760;
//         const longitude = 72.8777;

//         // Step 2: Determine categories to search
//         const categoriesToSearch =
//             type === 'All' ? Object.values(CATEGORY_MAP) : [CATEGORY_MAP[type]];

//         const results = [];

//         // Step 3: For each category, query Google Places
//         for (let category of categoriesToSearch) {
//             const url = `https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${latitude},${longitude}&radius=5000&type=${category}&key=${GOOGLE_API_KEY}`;
//             const { data } = await axios.get(url);

//             const top3 = data.results.slice(0, 3);
//             for (let place of top3) {
//                 await sendAlertToService(place.name, place.vicinity);
//                 results.push({ name: place.name, address: place.vicinity });
//             }
//         }

//         return res.json({ success: true, notified: results });

//     } catch (err) {
//         console.error('SOS error:', err);
//         return res.status(500).json({ error: 'Failed to trigger SOS' });
//     }
// };


module.exports = {
    // triggerSOS,
    getSOSHistory,
    addSOSHistory,
};

