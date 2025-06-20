const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
require('dotenv').config();

//-------------------------------------------------------------
// const cron = require("node-cron");
// const fetchGDACSDangerZones = require("./jobs/gdacsJob");

// cron.schedule("0 * * * *", () => {
//     console.log("🌀 Running GDACS Danger Zone Fetch Job");
//     fetchGDACSDangerZones();
//   });
  
// console.log("🌍 Danger Zone Fetcher Started");

//---------------------------------------------------------------

const authRoutes = require('./routes/authRoutes');
const profileRoutes = require('./routes/profileRoutes');
const contactRoutes = require('./routes/contactRoutes');
const sosRoutes = require('./routes/sosRoutes');
const emergencyRoutes = require('./routes/emergencyRoutes');

const app = express();
app.use(cors());
app.use(bodyParser.json());


//Routes
app.use('/auth', authRoutes);
app.use('/profile',profileRoutes);
app.use('/contacts', contactRoutes);
app.use('/sos', sosRoutes);
app.use('/emergency', emergencyRoutes);



const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));

