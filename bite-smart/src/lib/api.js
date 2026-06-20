const BASE_URL = 'https://bitesmart-production.up.railway.app/api';

async function request(path, options = {}) {
  const token = localStorage.getItem('admin_token');
  const headers = {
    'Content-Type': 'application/json',
    ...(token ? { 'Authorization': `Bearer ${token}` } : {}),
    ...options.headers,
  };

  const response = await fetch(`${BASE_URL}${path}`, {
    ...options,
    headers,
  });

  if (response.status === 401 || response.status === 403) {
    window.dispatchEvent(new CustomEvent('unauthorized_access'));
    throw new Error('Session expired or unauthorized access.');
  }

  if (!response.ok) {
    const errorData = await response.json().catch(() => ({}));
    throw new Error(errorData.message || `API request failed with status ${response.status}`);
  }

  if (response.status === 204) return null;
  const text = await response.text();
  try {
    return text ? JSON.parse(text) : null;
  } catch (e) {
    return text;
  }
}

function buildQuery(params) {
  const query = Object.entries(params)
    .filter(([_, val]) => val !== undefined && val !== null && val !== '')
    .map(([key, val]) => `${encodeURIComponent(key)}=${encodeURIComponent(val)}`)
    .join('&');
  return query ? `?${query}` : '';
}

export const AdminAPI = {
  getDashboard() {
    const timezone = Intl.DateTimeFormat().resolvedOptions().timeZone;
    const offset = String(-new Date().getTimezoneOffset());
    return request('/dashboard', {
      method: 'GET',
      headers: {
        'x-timezone': timezone,
        'x-timezone-offset': offset
      }
    });
  },

  getUsers(params = {}) {
    const defaultParams = { pageSize: 100, ...params };
    return request(`/users${buildQuery(defaultParams)}`, {
      method: 'GET'
    });
  },

  getUserById(id) {
    return request(`/users/${id}`, {
      method: 'GET'
    });
  },

  createUser(payload) {
    return request('/users', {
      method: 'POST',
      body: JSON.stringify(payload)
    });
  },

  updateUser(id, payload) {
    return request(`/users/${id}`, {
      method: 'PUT',
      body: JSON.stringify(payload)
    });
  },

  deleteUser(id) {
    return request(`/users/${id}`, {
      method: 'DELETE'
    });
  },

  getFoods(params = {}) {
    const defaultParams = { limit: 100, ...params };
    return request(`/food/db${buildQuery(defaultParams)}`, {
      method: 'GET'
    });
  },

  getFoodById(id) {
    return request(`/food/db/${id}`, {
      method: 'GET'
    });
  },

  createFood(payload) {
    return request('/food', {
      method: 'POST',
      body: JSON.stringify(payload)
    });
  },

  updateFood(id, payload) {
    return request(`/food/${id}`, {
      method: 'PUT',
      body: JSON.stringify(payload)
    });
  },

  deleteFood(id) {
    return request(`/food/${id}`, {
      method: 'DELETE'
    });
  },

  getChallenges(params = {}) {
    const defaultParams = { pageSize: 100, ...params };
    return request(`/challenges/admin${buildQuery(defaultParams)}`, {
      method: 'GET'
    });
  },

  getChallengeById(id) {
    return request(`/challenges/admin/${id}`, {
      method: 'GET'
    });
  },

  createChallenge(payload) {
    return request('/challenges/admin', {
      method: 'POST',
      body: JSON.stringify(payload)
    });
  },

  updateChallenge(id, payload) {
    return request(`/challenges/admin/${id}`, {
      method: 'PUT',
      body: JSON.stringify(payload)
    });
  },

  deleteChallenge(id) {
    return request(`/challenges/admin/${id}`, {
      method: 'DELETE'
    });
  },

  login(email, password) {
    return request('/auth/adminlogin', {
      method: 'POST',
      body: JSON.stringify({ email, password })
    });
  }
};
