const supabase = require('./supabaseClient');

async function getUserLocationFromDB(userId) {
  const { data, error } = await supabase
    .from('users')
    .select('latitude, longitude')
    .eq('id', userId)
    .single();

  if (error || !data) throw new Error('User location not found');

  return data;
}

module.exports = { getUserLocationFromDB };
