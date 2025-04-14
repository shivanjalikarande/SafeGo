const supabase = require('../utils/supabaseClient');

exports.registerUser = async (req, res) => {
  const { id, email, name, phone } = req.body;

  try {
    const { data, error } = await supabase
      .from('users')
      .insert([{ id, email, name, phone }]);

    if (error) return res.status(400).json({ error });

    return res.status(200).json({ message: 'User registered', data });
  } catch (err) {
    return res.status(500).json({ error: err.message });
  }
};

exports.checkUserExists = async (req, res) => {
  const { email } = req.body;

  console.log("Email: ",email);
  console.log("Request received on backend");

  try {
    const { data, error } = await supabase
      .from('users')
      .select('*')
      .eq('email', email)
      .single();

    if (error || !data) {
      return res.status(404).json({ message: 'User not found' });
    }

    return res.status(200).json({ message: 'User exists', user: data });
  } catch (err) {
    return res.status(500).json({ error: err.message });
  }
};
