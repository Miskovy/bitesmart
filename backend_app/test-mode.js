const axios = require('axios');

async function testMode() {
  try {
    const baseURL = 'http://localhost:3000/api';
    const email = `testuser_${Date.now()}@example.com`;
    const password = 'Password123!';
    const name = 'Test User';

    console.log(`1. Signing up user: ${email}`);
    const signupRes = await axios.post(`${baseURL}/auth/signup`, {
      email,
      password,
      name
    });
    
    const token = signupRes.data.data.token;
    console.log(`- Signup successful, token received`);

    console.log(`2. Updating mode (GLP-1: true, Ramadan: false)`);
    const updateRes = await axios.patch(`${baseURL}/profile/mode`, 
      { glp1: true, ramadanMode: false },
      { headers: { Authorization: `Bearer ${token}` } }
    );
    console.log(`- Mode update successful:`, updateRes.data.data);

    console.log(`3. Getting user profile to verify`);
    const profileRes = await axios.get(`${baseURL}/profile`, {
      headers: { Authorization: `Bearer ${token}` }
    });
    
    console.log(`- Profile data fetched`);
    console.log(`- GLP-1 Mode:`, profileRes.data.data.dietaryPreferences?.isGlp1User);
    console.log(`- Ramadan Mode:`, profileRes.data.data.dietaryPreferences?.isRamadanMode);
    
    process.exit(0);
  } catch (error) {
    console.error('Test failed:', error.response?.data || error.message);
    process.exit(1);
  }
}

setTimeout(testMode, 2000); // Wait for server to be fully ready
