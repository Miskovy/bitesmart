const axios = require('axios');
const CryptoJS = require('crypto-js');
const aiBaseurl = 'https://miskovy-bitesmart-ai.hf.space/api';
const aiApiKey = '8de0f9adbf4eda46437daa8a2f339d84f4b2830ca246827f60b7df43ef17dd20';
const aiApiSecret = '3766ef89d28c42a70a6280d80b83719cd47f5f4767f4e5230eae2dd2a3fba716';

const buildAuthHeaders = (method, path, data) => {
    const timestamp = Date.now().toString();
    const rawBody = data ? JSON.stringify(data).trim() : '';
    const bodyHash = CryptoJS.SHA256(rawBody).toString();
    const payload = timestamp + ':' + method.toUpperCase() + ':' + path + ':' + bodyHash;
    return {
        'X-Api-Key': aiApiKey,
        'X-Timestamp': timestamp,
        'X-Signature': CryptoJS.HmacSHA256(payload, aiApiSecret).toString(),
        'Content-Type': 'application/json'
    };
};

const data = { user_id: 'test', message: 'hello' };
const path = '/api/coach/chat';
const headers = buildAuthHeaders('POST', path, data);

axios.post(aiBaseurl + '/coach/chat', data, { headers })
  .then(r => console.log('Success:', r.data))
  .catch(e => console.log('Error:', e.response ? e.response.status + ' ' + JSON.stringify(e.response.data) : e.message));
