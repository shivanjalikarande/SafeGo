const { supabase } = require('../utils/supabaseClient');

// GET all contacts for a user
const getContactsByUser = async (req, res) => {
  const { userId } = req.params;

  const { data, error } = await supabase
    .from('emergency_contacts')
    .select('*')
    .eq('user_id', userId);

  if (error) {
    console.error('Error fetching contacts:', error.message);
    return res.status(500).json({ error: 'Failed to fetch contacts' });
  }

  return res.status(200).json(data);
};

// ADD a new contact
const addContact = async (req, res) => {
  const { user_id, name, phone, email, relation, address } = req.body;

  console.log("Attempting to add contact:", req.body);

  if (!user_id || !name || !phone || !email ||  !relation || !address) {
    return res.status(400).json({ error: 'Missing required fields' });
  }

  const { data, error } = await supabase
    .from('emergency_contacts')
    .insert([
      {
        user_id,
        name,
        phone,
        email,
        relation,
        address
      }
    ]);

  if (error) {
    console.error('Error adding contact:', error.message);
    return res.status(500).json({ error: 'Failed to add contact' });
  }

  return res.status(200).json({ message: 'Contact added successfully', data });
};

// DELETE a contact by ID
const deleteContact = async (req, res) => {
  const { id } = req.params;

  const { error } = await supabase
    .from('emergency_contacts')
    .delete()
    .eq('id', id);

  if (error) {
    console.error('Error deleting contact:', error.message);
    return res.status(500).json({ error: 'Failed to delete contact' });
  }

  return res.status(200).json({ message: 'Contact deleted successfully' });
};

module.exports = {
  getContactsByUser,
  addContact,
  deleteContact,
};
