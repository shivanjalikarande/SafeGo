const emergencyNumbers = require('../utils/data/emergencyNumbers.json');

const getEmergencyNumbers = (req, res) => {
  const { country } = req.query;
  console.log('Country for emergency service: ',country);

  if (!country) {
    return res.status(400).json({ error: 'Country is required' });
  }

  const numbers = emergencyNumbers[country];
  if (!numbers) {
    return res.status(404).json({ error: 'Emergency numbers not found for this country' });
  }

  return res.json({ country, emergencyNumbers: numbers });
};

module.exports = { getEmergencyNumbers };
