const { supabase } = require('../utils/supabaseClient');


const getUserProfile = async (req, res) => {
    const { id } = req.params;
  
    try {
      const { data, error } = await supabase
        .from('users')
        .select('name, phone, email') 
        .eq('id', id)
        .single(); 
  
      if (error) return res.status(400).json({ error: error.message });
  
      res.status(200).json(data);
    } catch (err) {
      console.error("Fetch Error:", err);
      res.status(500).json({ error: 'Internal server error' });
    }
  };
  
  

  const updateUserProfile = async (req, res) => {
    const { id, ...fieldsToUpdate } = req.body;
  
    Object.keys(fieldsToUpdate).forEach(key => {
      if (
        fieldsToUpdate[key] === undefined ||
        fieldsToUpdate[key] === null ||
        fieldsToUpdate[key] === ''
      ) {
        delete fieldsToUpdate[key];
      }
    });
  
    if (!id || Object.keys(fieldsToUpdate).length === 0) {
      return res.status(400).json({ error: 'No fields to update or ID missing' });
    }
  
    try {
      const { error } = await supabase
        .from('users')
        .update(fieldsToUpdate)
        .eq('id', id);
  
      if (error) return res.status(400).json({ error: error.message });
  
      res.status(200).json({ message: 'Profile updated successfully' });
    } catch (err) {
      console.error("Update Error:", err);
      res.status(500).json({ error: 'Internal server error' });
    }
  };
  

  module.exports = {
    getUserProfile,
    updateUserProfile,
  };