const { supabase } = require('../utils/supabaseClient');


const getUserProfile = async (req, res) => {
    const { id } = req.params;
  
    try {
      const { data: userProfile, error: userError} = await supabase
        .from('users')
        .select('name, phone, email') 
        .eq('id', id)
        .single(); 
  
      if (userError) return res.status(400).json({ error: userError.message });

      const { data: authUser, error: authError } = await supabase.auth.admin.getUserById(id);

      if (authError) return res.status(400).json({ error: authError.message });
  
      const profileImage = authUser?.user?.user_metadata?.profile_picture || null;
      // console.log("User metadata: ",authUser.user.user_metadata);

      // console.log("profile Image: ",profileImage);
  
      res.status(200).json({
        ...userProfile,
        profile_image: profileImage,
      });
  
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

 const updateProfileImage =  async (req, res) => {
    const { user_id, profile_picture } = req.body;
    console.log("Inside image upload backend call");
    try {
      await supabase
        .from('users')
        .update({ profile_picture })
        .eq("id", user_id);
  
      res.status(200).json({ message: "Image updated" });
    } catch (error) {
      res.status(500).json({ error: "Update failed" });
    }
  };
  
  

  module.exports = {
    getUserProfile,
    updateUserProfile,
    updateProfileImage
  };