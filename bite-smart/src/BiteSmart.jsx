import { useState, useEffect } from "react";
import {
  AreaChart, Area, BarChart, Bar, PieChart, Pie, Cell,
  XAxis, YAxis, Tooltip, ResponsiveContainer, LineChart, Line,
} from "recharts";
import {
  LayoutDashboard, Users, Apple, ClipboardList, BarChart2,
  Bell, Settings, Shield, FileText, Search, Plus, Activity,
  Server, DollarSign, ChevronRight, Edit, Trash2, Eye,
  LogOut, AlertTriangle, Leaf, RefreshCw, Menu,
  X, Check, Download, TrendingUp, TrendingDown, Globe,
  CheckCircle, XCircle, Target, Calendar
} from "lucide-react";

import { AdminAPI } from "./lib/api";

// ─── TOAST NOTIFICATIONS ────────────────────────────────────────────────────────
export function showToast(message, type = 'success') {
  window.dispatchEvent(new CustomEvent('show_toast', { detail: { message, type } }));
}

function ToastContainer() {
  const [toasts, setToasts] = useState([]);

  useEffect(() => {
    const handler = (e) => {
      const id = Date.now() + Math.random();
      setToasts(prev => [...prev, { id, ...e.detail }]);
      setTimeout(() => {
        setToasts(prev => prev.filter(t => t.id !== id));
      }, 4000);
    };

    const handleAuthError = () => {
      localStorage.removeItem('admin_token');
      localStorage.removeItem('admin_profile');
      showToast('Session expired or unauthorized access. Please check your token.', 'error');
    };

    window.addEventListener('show_toast', handler);
    window.addEventListener('unauthorized_access', handleAuthError);
    return () => {
      window.removeEventListener('show_toast', handler);
      window.removeEventListener('unauthorized_access', handleAuthError);
    };
  }, []);

  return (
    <div style={{ position:'fixed', bottom: 24, right: 24, display:'flex', flexDirection:'column', gap:10, zIndex: 9999, pointerEvents:'none' }}>
      {toasts.map(t => (
        <div key={t.id} style={{
          background: t.type === 'error' ? '#f87171' : '#22c55e',
          color: t.type === 'error' ? '#fff' : '#000',
          padding: '12px 20px',
          borderRadius: 8,
          fontWeight: 600,
          fontSize: 13,
          boxShadow: '0 8px 24px rgba(0,0,0,0.3)',
          display: 'flex',
          alignItems: 'center',
          gap: 8,
          pointerEvents: 'auto'
        }}>
          {t.type === 'error' ? <XCircle size={16} /> : <CheckCircle size={16} />}
          {t.message}
        </div>
      ))}
    </div>
  );
}

// ─── Design Tokens ────────────────────────────────────────────────────────────
const T = {
  bg:      '#060d09',
  surf:    '#0b1610',
  card:    '#0f1d13',
  cardHov: '#152219',
  border:  '#1a3022',
  green:   '#22c55e',
  greenD:  '#16a34a',
  greenL:  '#4ade80',
  glow:    'rgba(34,197,94,0.12)',
  text:    '#dff0e5',
  muted:   '#5a8a6a',
  dim:     '#2a4838',
  red:     '#f87171',
  amber:   '#fbbf24',
  blue:    '#60a5fa',
  purple:  '#a78bfa',
};

// ─── UI Mappings & Nav ────────────────────────────────────────────────────────
const catColor = { Protein:T.blue, Grain:T.amber, Fat:T.green, Dairy:T.purple, Vegetable:T.greenL, Legume:T.amber };

const navItems = [
  { id:'dashboard',     label:'Dashboard',     Icon:LayoutDashboard },
  { id:'users',         label:'Users',         Icon:Users             },
  { id:'foods',         label:'Food Database', Icon:Apple             },
  { id:'plans',         label:'Meal Plans',    Icon:ClipboardList     },
  { id:'challenges',    label:'Challenges',    Icon:Target            },
  { id:'analytics',     label:'Analytics',     Icon:BarChart2         },
  { id:'notifications', label:'Notifications', Icon:Bell              },
  { id:'content',       label:'Content',       Icon:FileText          },
  { id:'security',      label:'Security',      Icon:Shield            },
  { id:'settings',      label:'Settings',      Icon:Settings          },
];

const pageLabels = {
  dashboard:'Dashboard', users:'User Management', foods:'Food Database',
  plans:'Meal Plans', challenges:'Community Challenges', analytics:'Analytics', notifications:'Notifications',
  content:'Content', security:'Security', settings:'Settings',
};

function uid() { return Date.now() + Math.floor(Math.random() * 1000); }

// ─── Shared UI Components ─────────────────────────────────────────────────────
function Card({ children, style = {}, onClick }) {
  return <div onClick={onClick} style={{ background:T.card, border:`1px solid ${T.border}`, borderRadius:12, ...style }}>{children}</div>;
}

function Badge({ children, color = T.green, bg }) {
  return <span style={{ display:'inline-block', padding:'2px 10px', borderRadius:20, fontSize:11, fontWeight:600, color, background: bg || `${color}1a` }}>{children}</span>;
}

function Btn({ children, onClick, variant='primary', size='md', style={}, disabled=false, type='button' }) {
  const base = { display:'flex', alignItems:'center', gap:6, borderRadius:8, cursor:disabled?'not-allowed':'pointer', fontWeight:600, border:'none', transition:'opacity .15s', opacity:disabled?0.5:1, ...style };
  const sizes = { sm:'6px 11px', md:'8px 16px', lg:'10px 22px' };
  const variants = {
    primary: { background:T.green, color:'#000', fontSize:12 },
    ghost:   { background:'none', border:`1px solid ${T.border}`, color:T.muted, fontSize:12 },
    danger:  { background:`${T.red}18`, border:`1px solid ${T.red}40`, color:T.red, fontSize:12 },
    success: { background:`${T.green}18`, border:`1px solid ${T.green}40`, color:T.green, fontSize:12 },
  };
  return <button type={type} onClick={disabled?undefined:onClick} style={{ ...base, ...variants[variant], padding:sizes[size] }}>{children}</button>;
}

function Modal({ open, onClose, title, children, width=480 }) {
  useEffect(() => {
    const handler = (e) => { if (e.key === 'Escape') onClose(); };
    if (open) window.addEventListener('keydown', handler);
    return () => window.removeEventListener('keydown', handler);
  }, [open, onClose]);

  if (!open) return null;
  return (
    <div style={{ position:'fixed', inset:0, zIndex:1000, display:'flex', alignItems:'center', justifyContent:'center', background:'rgba(0,0,0,0.7)', backdropFilter:'blur(4px)' }} onClick={e => { if (e.target === e.currentTarget) onClose(); }}>
      <div style={{ background:T.surf, border:`1px solid ${T.border}`, borderRadius:16, width, maxWidth:'95vw', maxHeight:'90vh', overflow:'auto', boxShadow:'0 24px 80px rgba(0,0,0,0.6)' }}>
        <div style={{ display:'flex', alignItems:'center', justifyContent:'space-between', padding:'18px 22px', borderBottom:`1px solid ${T.border}` }}>
          <div style={{ fontSize:14, fontWeight:700, color:T.text }}>{title}</div>
          <button onClick={onClose} style={{ background:'none', border:'none', cursor:'pointer', color:T.muted, display:'flex', alignItems:'center' }}><X size={16}/></button>
        </div>
        <div style={{ padding:22 }}>{children}</div>
      </div>
    </div>
  );
}

function ConfirmModal({ open, onClose, onConfirm, title, message, danger=false }) {
  return (
    <Modal open={open} onClose={onClose} title={title} width={380}>
      <p style={{ fontSize:13, color:T.muted, marginBottom:20, lineHeight:1.6 }}>{message}</p>
      <div style={{ display:'flex', gap:10, justifyContent:'flex-end' }}>
        <Btn variant="ghost" onClick={onClose}>Cancel</Btn>
        <Btn variant={danger?'danger':'primary'} onClick={()=>{ onConfirm(); onClose(); }}>
          {danger ? <><Trash2 size={13}/>Delete</> : <><Check size={13}/>Confirm</>}
        </Btn>
      </div>
    </Modal>
  );
}

function FieldRow({ label, children }) {
  return (
    <div style={{ marginBottom:16 }}>
      <div style={{ fontSize:10, color:T.muted, fontWeight:700, textTransform:'uppercase', letterSpacing:'0.08em', marginBottom:6 }}>{label}</div>
      {children}
    </div>
  );
}

function Input({ value, onChange, placeholder, type='text', style={} }) {
  return <input type={type} value={value} onChange={onChange} placeholder={placeholder} style={{ width:'100%', background:T.card, border:`1px solid ${T.border}`, borderRadius:8, padding:'9px 13px', color:T.text, fontSize:13, outline:'none', boxSizing:'border-box', ...style }} />;
}

function Select({ value, onChange, children, style={} }) {
  return <select value={value} onChange={onChange} style={{ width:'100%', background:T.card, border:`1px solid ${T.border}`, borderRadius:8, padding:'9px 13px', color:T.text, fontSize:13, outline:'none', boxSizing:'border-box', ...style }}>{children}</select>;
}

function Textarea({ value, onChange, placeholder, rows=3 }) {
  return <textarea value={value} onChange={onChange} placeholder={placeholder} rows={rows} style={{ width:'100%', background:T.card, border:`1px solid ${T.border}`, borderRadius:8, padding:'9px 13px', color:T.text, fontSize:13, outline:'none', boxSizing:'border-box', resize:'vertical' }} />;
}

// ─── FORMS ────────────────────────────────────────────────────────────────────
function UserForm({ form, setForm, onSave, isSaving, onCancel }) {
  return (
    <>
      <FieldRow label="Full name"><Input value={form.name} onChange={e=>setForm(p=>({...p,name:e.target.value}))} placeholder="e.g. Amira Hassan" /></FieldRow>
      <FieldRow label="Email"><Input type="email" value={form.email} onChange={e=>setForm(p=>({...p,email:e.target.value}))} placeholder="user@email.com" /></FieldRow>
      <div style={{ display:'grid', gridTemplateColumns:'1fr 1fr', gap:12 }}>
        <FieldRow label="Plan">
          <Select value={form.plan} onChange={e=>setForm(p=>({...p,plan:e.target.value}))}><option>Free</option><option>Pro</option><option>Family</option></Select>
        </FieldRow>
        <FieldRow label="Status">
          <Select value={form.status} onChange={e=>setForm(p=>({...p,status:e.target.value}))}><option>Active</option><option>Inactive</option></Select>
        </FieldRow>
      </div>
      <FieldRow label="Country"><Input value={form.country} onChange={e=>setForm(p=>({...p,country:e.target.value}))} placeholder="e.g. Egypt" /></FieldRow>
      <div style={{ display:'flex', gap:10, justifyContent:'flex-end', marginTop:8 }}>
        <Btn variant="ghost" onClick={onCancel}>Cancel</Btn>
        <Btn disabled={isSaving} onClick={onSave}><Check size={13}/>{isSaving ? 'Saving...' : 'Save changes'}</Btn>
      </div>
    </>
  );
}

function FoodForm({ form, setForm, onSave, isSaving, onCancel, cats }) {
  return (
    <>
      <FieldRow label="Food name"><Input value={form.name} onChange={e=>setForm(p=>({...p,name:e.target.value}))} placeholder="e.g. Grilled Chicken Breast" /></FieldRow>
      <div style={{ display:'grid', gridTemplateColumns:'1fr 1fr', gap:12 }}>
        <FieldRow label="Category">
          <Select value={form.cat} onChange={e=>setForm(p=>({...p,cat:e.target.value}))}>{cats.filter(c=>c!=='All').map(c=><option key={c}>{c}</option>)}</Select>
        </FieldRow>
        <FieldRow label="Status">
          <Select value={form.status} onChange={e=>setForm(p=>({...p,status:e.target.value}))}><option>Pending</option><option>Approved</option></Select>
        </FieldRow>
      </div>
      <div style={{ display:'grid', gridTemplateColumns:'repeat(4,1fr)', gap:10 }}>
        {[['Calories (kcal)','cal'],['Protein (g)','protein'],['Carbs (g)','carbs'],['Fat (g)','fat']].map(([label,key]) => (
          <FieldRow key={key} label={label}><Input type="number" value={form[key]} onChange={e=>setForm(p=>({...p,[key]:e.target.value}))} placeholder="0" /></FieldRow>
        ))}
      </div>
      <div style={{ display:'flex', gap:10, justifyContent:'flex-end', marginTop:8 }}>
        <Btn variant="ghost" onClick={onCancel}>Cancel</Btn>
        <Btn disabled={isSaving} onClick={onSave}><Check size={13}/>{isSaving ? 'Saving...' : 'Save changes'}</Btn>
      </div>
    </>
  );
}

function KpiCard({ Icon, label, value, change, up=true, color }) {
  return (
    <Card style={{ padding:'18px 20px' }}>
      <div style={{ display:'flex', alignItems:'center', justifyContent:'space-between', marginBottom:12 }}>
        <div style={{ width:34, height:34, borderRadius:9, background:`${color}18`, display:'flex', alignItems:'center', justifyContent:'center' }}><Icon size={17} color={color} /></div>
        <span style={{ fontSize:11, color: up ? T.green : T.red, fontWeight:600 }}>{up ? '▲' : '▼'} {change}</span>
      </div>
      <div style={{ fontSize:24, fontWeight:800, color:T.text, letterSpacing:'-0.02em' }}>{value}</div>
      <div style={{ fontSize:12, color:T.muted, marginTop:3 }}>{label}</div>
    </Card>
  );
}

// ─── DASHBOARD PAGE ───────────────────────────────────────────────────────────
function DashboardPage() {
  const [data, setData] = useState({ users: 0, meals: 0, revenue: 0, health: "100%" });
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    AdminAPI.getDashboard()
      .then(res => {
        if (res) {
          setData({
            users: res.users ?? res.usersCount ?? res.activeUsers ?? 0,
            meals: res.meals ?? res.mealsCount ?? res.mealsLogged ?? 0,
            revenue: res.revenue ?? res.monthlyRevenue ?? 0,
            health: res.health ?? res.systemHealth ?? "100%",
            areaData: res.areaData ?? res.activity ?? res.dailyActivity ?? [],
            pieData: res.pieData ?? res.distribution ?? res.planDistribution ?? []
          });
        }
      })
      .catch(err => {
        console.error("Dashboard API fetch failed:", err);
        showToast(err.message || "Failed to load dashboard data", "error");
      })
      .finally(() => setLoading(false));
  }, []);

  if (loading) {
    return <div style={{ color: T.muted, padding: 80, textAlign: 'center', fontSize: 13 }}>Loading dashboard insights...</div>;
  }

  // Fallback beautiful datasets if backend returns empty charts
  const areaData = data.areaData && data.areaData.length > 0 ? data.areaData : [
    { day: 'Mon', users: 10, meals: 15 },
    { day: 'Tue', users: 15, meals: 25 },
    { day: 'Wed', users: 22, meals: 38 },
    { day: 'Thu', users: 30, meals: 45 },
    { day: 'Fri', users: 42, meals: 68 },
    { day: 'Sat', users: 55, meals: 90 },
    { day: 'Sun', users: data.users || 65, meals: data.meals || 110 }
  ];

  const rawPieData = data.pieData && data.pieData.length > 0 ? data.pieData : [
    { name: 'Free', value: 45 },
    { name: 'Pro', value: 35 },
    { name: 'Family', value: 20 }
  ];

  const pieData = rawPieData.map(item => ({
    name: item.name || item.label || 'Plan',
    value: item.value ?? item.count ?? item.v ?? 0,
    v: item.v ?? item.value ?? item.count ?? 0
  }));

  const COLORS = [T.green, T.blue, T.amber, T.purple, T.red];

  return (
    <div style={{ display:'flex', flexDirection:'column', gap:20 }}>
      <div style={{ display:'grid', gridTemplateColumns:'repeat(4,1fr)', gap:16 }}>
        <KpiCard Icon={Users}      label="Active users"       value={data.users}  change="12%"  color={T.green} />
        <KpiCard Icon={Activity}   label="Meals logged today" value={data.meals}  change="8%" color={T.blue}  />
        <KpiCard Icon={DollarSign} label="Monthly revenue"    value={`$${data.revenue}`} change="5%"  color={T.amber} />
        <KpiCard Icon={Server}     label="System health"      value={data.health} change="0.1%"  color={T.green} />
      </div>
      
      <div style={{ display:'grid', gridTemplateColumns:'2fr 1fr', gap:16 }}>
        <Card style={{ padding:'20px 20px 12px' }}>
          <div style={{ display:'flex', alignItems:'center', justifyContent:'space-between', marginBottom:16 }}>
            <div>
              <div style={{ fontSize:14, fontWeight:600, color:T.text }}>User &amp; meal activity</div>
              <div style={{ fontSize:11, color:T.muted }}>Real-time updates from backend logs</div>
            </div>
          </div>
          <ResponsiveContainer width="100%" height={180}>
            <AreaChart data={areaData}>
              <defs>
                <linearGradient id="colorUsers" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="5%" stopColor={T.green} stopOpacity={0.2}/>
                  <stop offset="95%" stopColor={T.green} stopOpacity={0}/>
                </linearGradient>
                <linearGradient id="colorMeals" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="5%" stopColor={T.blue} stopOpacity={0.2}/>
                  <stop offset="95%" stopColor={T.blue} stopOpacity={0}/>
                </linearGradient>
              </defs>
              <XAxis dataKey="day" tick={{ fill:T.dim, fontSize:10 }} axisLine={false} tickLine={false} />
              <YAxis tick={{ fill:T.dim, fontSize:10 }} axisLine={false} tickLine={false} />
              <Tooltip contentStyle={{ background:T.card, border:`1px solid ${T.border}`, borderRadius:8, color:T.text, fontSize:11 }} />
              <Area type="monotone" dataKey="users" stroke={T.green} fillOpacity={1} fill="url(#colorUsers)" name="Active Users" />
              <Area type="monotone" dataKey="meals" stroke={T.blue} fillOpacity={1} fill="url(#colorMeals)" name="Meals Logged" />
            </AreaChart>
          </ResponsiveContainer>
        </Card>
        
        <Card style={{ padding:20 }}>
          <div style={{ fontSize:14, fontWeight:600, color:T.text, marginBottom:4 }}>Plan distribution</div>
          <div style={{ fontSize:11, color:T.muted, marginBottom:12 }}>Distribution of registered accounts</div>
          <ResponsiveContainer width="100%" height={120}>
            <PieChart>
              <Pie data={pieData} cx="50%" cy="50%" innerRadius={36} outerRadius={55} paddingAngle={3} dataKey="v" nameKey="name">
                {pieData.map((entry, index) => (
                  <Cell key={`cell-${index}`} fill={COLORS[index % COLORS.length]} />
                ))}
              </Pie>
              <Tooltip contentStyle={{ background:T.card, border:`1px solid ${T.border}`, borderRadius:8, color:T.text, fontSize:11 }} />
            </PieChart>
          </ResponsiveContainer>
        </Card>
      </div>
    </div>
  );
}

// ─── USERS PAGE ───────────────────────────────────────────────────────────────
function UsersPage() {
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [filter, setFilter] = useState('All');
  const [showAdd, setShowAdd] = useState(false);
  const [editUser, setEditUser] = useState(null);
  const [viewUser, setViewUser] = useState(null);
  const [loadingDetails, setLoadingDetails] = useState(false);
  const [deleteId, setDeleteId] = useState(null);
  const [isSaving, setIsSaving] = useState(false);
  
  const [form, setForm] = useState({ name:'', email:'', plan:'Free', status:'Active', country:'Egypt' });
  const planColor = { Pro:T.green, Free:T.muted, Family:T.blue };
  const filters = ['All','Pro','Free','Family','Active','Inactive'];

  useEffect(() => {
    fetchUsers();
  }, []);

  const mapUser = u => ({
    id: u.id || u._id,
    name: u.name,
    email: u.email,
    plan: u.role || 'Free',
    status: u.is_active !== false ? 'Active' : 'Inactive',
    meals: u.meals || 0,
    joined: u.createdAt ? new Date(u.createdAt).toLocaleDateString() : 'Unknown',
    country: u.country || 'Not set',
    verified: !!u.verified
  });

  async function fetchUsers() {
    try {
      setLoading(true);
      const res = await AdminAPI.getUsers();
      const raw = Array.isArray(res) ? res : (res.users || res.data || []);
      setUsers(raw.map(mapUser));
    } catch (error) {
      console.error("API fetch failed.", error);
      showToast(error.message || "Failed to load users", "error");
      setUsers([]); 
    } finally {
      setLoading(false);
    }
  }

  async function viewUserDetails(u) {
    try {
      setLoadingDetails(true);
      setViewUser(u);
      const res = await AdminAPI.getUserById(u.id);
      if (res) {
        const fetched = res.user || res.data || res;
        setViewUser(prev => {
          if (!prev) return null;
          return {
            ...prev,
            age: fetched.age,
            gender: fetched.gender,
            height: fetched.height,
            weight: fetched.weight,
            activityLevel: fetched.activityLevel,
            userGoal: fetched.userGoal,
            plan: fetched.role || prev.plan,
            status: fetched.is_active !== false ? 'Active' : 'Inactive',
            country: fetched.country || prev.country
          };
        });
      }
    } catch (err) {
      console.error("Failed to load user details:", err);
    } finally {
      setLoadingDetails(false);
    }
  }

  const filtered = users.filter(u =>
    (filter === 'All' || u.plan === filter || u.status === filter) &&
    (u.name?.toLowerCase().includes(search.toLowerCase()) || u.email?.toLowerCase().includes(search.toLowerCase()))
  );

  function openAdd() { setForm({ name:'', email:'', plan:'Free', status:'Active', country:'Egypt' }); setShowAdd(true); }
  function openEdit(u) { setForm({ name:u.name, email:u.email, plan:u.plan, status:u.status, country:u.country }); setEditUser(u); }

  async function saveAdd() {
    if (!form.name || !form.email) {
      showToast("Name and email are required", "error");
      return;
    }
    setIsSaving(true);
    try {
      const payload = {
        name: form.name,
        email: form.email,
        password: "DefaultPassword123!",
        role: form.plan,
        country: form.country,
        is_active: form.status === 'Active'
      };
      const newUser = await AdminAPI.createUser(payload);
      setUsers(prev => [...prev, mapUser(newUser)]);
      setShowAdd(false);
      showToast("User created successfully");
    } catch (err) {
      console.error("Failed to create user", err);
      showToast(err.message || "Failed to create user", "error");
    } finally {
      setIsSaving(false);
    }
  }

  async function saveEdit() {
    if (!form.name || !form.email) {
      showToast("Name and email are required", "error");
      return;
    }
    setIsSaving(true);
    try {
      const payload = {
        name: form.name,
        email: form.email,
        role: form.plan,
        country: form.country,
        is_active: form.status === 'Active'
      };
      const updatedUser = await AdminAPI.updateUser(editUser.id, payload);
      setUsers(prev => prev.map(u => u.id === editUser.id ? mapUser(updatedUser) : u));
      setEditUser(null);
      showToast("User updated successfully");
    } catch (err) {
      console.error("Failed to update user", err);
      showToast(err.message || "Failed to update user", "error");
    } finally {
      setIsSaving(false);
    }
  }

  async function doDelete() {
    try {
      await AdminAPI.deleteUser(deleteId);
      setUsers(prev => prev.filter(u => u.id !== deleteId));
      showToast("User deleted");
    } catch (err) {
      console.error("Failed to delete user", err);
      showToast(err.message || "Failed to delete user", "error");
    } finally {
      setDeleteId(null);
    }
  }

  if (loading) return <div style={{ color: T.muted, padding: 40, textAlign: 'center', fontSize: 13 }}>Fetching users from backend...</div>;

  return (
    <div style={{ display:'flex', flexDirection:'column', gap:16 }}>
      <div style={{ display:'flex', alignItems:'center', gap:10, flexWrap:'wrap' }}>
        <div style={{ position:'relative', flex:1, minWidth:180 }}>
          <Search size={14} color={T.muted} style={{ position:'absolute', left:11, top:'50%', transform:'translateY(-50%)', pointerEvents:'none' }} />
          <input value={search} onChange={e=>setSearch(e.target.value)} placeholder="Search users…"
            style={{ width:'100%', background:T.card, border:`1px solid ${T.border}`, borderRadius:8, padding:'8px 12px 8px 34px', color:T.text, fontSize:13, outline:'none', boxSizing:'border-box' }} />
        </div>
        <div style={{ display:'flex', gap:6, flexWrap:'wrap' }}>
          {filters.map(f => (
            <button key={f} onClick={() => setFilter(f)} style={{ padding:'7px 13px', borderRadius:7, fontSize:12, cursor:'pointer', fontWeight:500, background:filter===f?T.green:T.card, color:filter===f?'#000':T.muted, border:`1px solid ${filter===f?T.green:T.border}` }}>{f}</button>
          ))}
        </div>
        <Btn onClick={openAdd}><Plus size={14}/> Add user</Btn>
      </div>

      <Card>
        <div style={{ overflowX:'auto' }}>
          <table style={{ width:'100%', borderCollapse:'collapse', fontSize:13 }}>
            <thead>
              <tr style={{ borderBottom:`1px solid ${T.border}` }}>
                {['User','Email','Plan','Status','Meals','Joined','Actions'].map(h => (
                  <th key={h} style={{ padding:'12px 16px', textAlign:'left', fontSize:10, fontWeight:700, color:T.muted, letterSpacing:'0.08em', textTransform:'uppercase', whiteSpace:'nowrap' }}>{h}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {filtered.map((u, i) => (
                <tr key={u.id} style={{ borderBottom:i<filtered.length-1?`1px solid ${T.border}`:'none', transition:'background .15s' }}
                  onMouseEnter={e=>e.currentTarget.style.background=T.cardHov} onMouseLeave={e=>e.currentTarget.style.background='transparent'}>
                  <td style={{ padding:'11px 16px' }}>
                    <div style={{ display:'flex', alignItems:'center', gap:10 }}>
                      <div style={{ width:32, height:32, borderRadius:'50%', background:T.glow, border:`1.5px solid ${T.green}30`, display:'flex', alignItems:'center', justifyContent:'center', fontSize:11, fontWeight:700, color:T.green, flexShrink:0 }}>
                        {u.name?.split(' ').map(n=>n[0]).join('') || '?'}
                      </div>
                      <div>
                        <div style={{ color:T.text, fontWeight:500 }}>{u.name}</div>
                        {u.verified && <div style={{ fontSize:10, color:T.green }}>✓ Verified</div>}
                      </div>
                    </div>
                  </td>
                  <td style={{ padding:'11px 16px', color:T.muted }}>{u.email}</td>
                  <td style={{ padding:'11px 16px' }}><Badge color={planColor[u.plan] || T.muted}>{u.plan || 'Free'}</Badge></td>
                  <td style={{ padding:'11px 16px' }}><Badge color={u.status==='Active'?T.green:T.red}>{u.status || 'Active'}</Badge></td>
                  <td style={{ padding:'11px 16px', color:T.text, fontWeight:600 }}>{u.meals?.toLocaleString() || 0}</td>
                  <td style={{ padding:'11px 16px', color:T.muted, whiteSpace:'nowrap' }}>{u.joined || 'Unknown'}</td>
                  <td style={{ padding:'11px 16px' }}>
                    <div style={{ display:'flex', gap:6 }}>
                      <button onClick={()=>viewUserDetails(u)} style={{ background:'none', border:`1px solid ${T.border}`, borderRadius:6, cursor:'pointer', color:T.muted, padding:'5px 7px', display:'flex', alignItems:'center' }}><Eye size={13}/></button>
                      <button onClick={()=>openEdit(u)} style={{ background:'none', border:`1px solid ${T.border}`, borderRadius:6, cursor:'pointer', color:T.muted, padding:'5px 7px', display:'flex', alignItems:'center' }}><Edit size={13}/></button>
                      <button onClick={()=>setDeleteId(u.id)} style={{ background:'none', border:`1px solid ${T.border}`, borderRadius:6, cursor:'pointer', color:T.red, padding:'5px 7px', display:'flex', alignItems:'center' }}><Trash2 size={13}/></button>
                    </div>
                  </td>
                </tr>
              ))}
              {filtered.length === 0 && <tr><td colSpan={7} style={{ padding:32, textAlign:'center', color:T.muted, fontSize:13 }}>No users match your search (or database is empty).</td></tr>}
            </tbody>
          </table>
        </div>
        <div style={{ padding:'12px 16px', borderTop:`1px solid ${T.border}`, display:'flex', alignItems:'center', justifyContent:'space-between', fontSize:12, color:T.muted }}>
          <span>Showing {filtered.length} of {users.length} users</span>
        </div>
      </Card>

      <Modal open={showAdd} onClose={()=>setShowAdd(false)} title="Add new user">
        <UserForm form={form} setForm={setForm} onSave={saveAdd} isSaving={isSaving} onCancel={() => setShowAdd(false)} />
      </Modal>

      <Modal open={!!editUser} onClose={()=>setEditUser(null)} title={`Edit — ${editUser?.name}`}>
        <UserForm form={form} setForm={setForm} onSave={saveEdit} isSaving={isSaving} onCancel={() => setEditUser(null)} />
      </Modal>

      <Modal open={!!viewUser} onClose={()=>setViewUser(null)} title="User profile" width={400}>
        {viewUser && (
          <div style={{ display:'flex', flexDirection:'column', gap:16 }}>
            <div style={{ display:'flex', alignItems:'center', gap:14 }}>
              <div style={{ width:52, height:52, borderRadius:'50%', background:T.glow, border:`2px solid ${T.green}40`, display:'flex', alignItems:'center', justifyContent:'center', fontSize:16, fontWeight:800, color:T.green }}>
                {viewUser.name?.split(' ').map(n=>n[0]).join('') || '?'}
              </div>
              <div>
                <div style={{ display:'flex', alignItems:'center', gap:8 }}>
                  <div style={{ fontSize:15, fontWeight:700, color:T.text }}>{viewUser.name}</div>
                  {loadingDetails && <span style={{ fontSize:10, color:T.muted, fontStyle:'italic' }}>(Loading info...)</span>}
                </div>
                <div style={{ fontSize:12, color:T.muted }}>{viewUser.email}</div>
              </div>
            </div>
            {[
              ['Plan', <Badge color={({Pro:T.green,Free:T.muted,Family:T.blue})[viewUser.plan]}>{viewUser.plan}</Badge>],
              ['Status', <Badge color={viewUser.status==='Active'?T.green:T.red}>{viewUser.status}</Badge>],
              ['Country', viewUser.country || 'Not set'],
              ['Age', viewUser.age ? `${viewUser.age} yrs` : 'Not set'],
              ['Gender', viewUser.gender || 'Not set'],
              ['Height', viewUser.height ? `${viewUser.height} cm` : 'Not set'],
              ['Weight', viewUser.weight ? `${viewUser.weight} kg` : 'Not set'],
              ['Activity Level', viewUser.activityLevel || 'Not set'],
              ['Goal', viewUser.userGoal || 'Not set'],
              ['Meals logged', viewUser.meals?.toLocaleString() || 0],
              ['Joined', viewUser.joined || 'Unknown'],
              ['Verified', viewUser.verified ? '✓ Yes' : '✗ No']
            ].map(([k,v],i) => (
              <div key={i} style={{ display:'flex', justifyContent:'space-between', alignItems:'center', padding:'10px 0', borderBottom:`1px solid ${T.border}` }}>
                <span style={{ fontSize:12, color:T.muted }}>{k}</span>
                <span style={{ fontSize:12, color:T.text, fontWeight:600 }}>{v}</span>
              </div>
            ))}
          </div>
        )}
      </Modal>

      <ConfirmModal open={!!deleteId} onClose={()=>setDeleteId(null)} onConfirm={doDelete}
        title="Delete user" message="This action is permanent and cannot be undone. Are you sure you want to delete this user and all their data?" danger />
    </div>
  );
}

// ─── CHALLENGES PAGE ──────────────────────────────────────────────────────────
function ChallengesPage() {
  const [challenges, setChallenges] = useState([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [showAdd, setShowAdd] = useState(false);
  const [editItem, setEditItem] = useState(null);
  const [deleteId, setDeleteId] = useState(null);
  const [isSaving, setIsSaving] = useState(false);

  const [form, setForm] = useState({ 
    title: '', description: '', points: '', status: 'Draft', startDate: '', endDate: '' 
  });

  const statusColor = { Active: T.green, Draft: T.muted, Completed: T.blue };

  useEffect(() => {
    fetchChallenges();
  }, []);

  const mapChallenge = c => {
    let start = '';
    let end = '';
    try {
      if (c.startDate) start = new Date(c.startDate).toISOString().split('T')[0];
    } catch(e) {}
    try {
      if (c.endDate) end = new Date(c.endDate).toISOString().split('T')[0];
    } catch(e) {}
    return {
      id: c.id || c._id,
      title: c.title,
      description: c.description,
      points: c.points || 100,
      status: c.status || 'Active',
      startDate: start,
      endDate: end,
    };
  };

  async function fetchChallenges() {
    try {
      setLoading(true);
      const res = await AdminAPI.getChallenges();
      const raw = Array.isArray(res) ? res : (res.data || []);
      setChallenges(raw.map(mapChallenge));
    } catch (error) {
      console.error("API fetch failed.", error);
      showToast(error.message || "Failed to load challenges", "error");
      setChallenges([]);
    } finally {
      setLoading(false);
    }
  }

  function openAdd() { setForm({ title: '', description: '', points: '', status: 'Draft', startDate: '', endDate: '' }); setShowAdd(true); }
  function openEdit(c) { setForm({ title: c.title, description: c.description, points: String(c.points), status: c.status, startDate: c.startDate, endDate: c.endDate }); setEditItem(c); }

  async function saveAdd() {
    if (!form.title) {
      showToast("Challenge title is required", "error");
      return;
    }
    setIsSaving(true);
    try {
      const payload = {
        title: form.title,
        description: form.description,
        startDate: form.startDate ? new Date(form.startDate).toISOString() : undefined,
        endDate: form.endDate ? new Date(form.endDate).toISOString() : undefined
      };
      const newChallenge = await AdminAPI.createChallenge(payload);
      setChallenges(prev => [...prev, mapChallenge(newChallenge)]);
      setShowAdd(false);
      showToast("Challenge created successfully");
    } catch (error) {
      console.error("Failed to create challenge", error);
      showToast(error.message || "Failed to create challenge", "error");
    } finally {
      setIsSaving(false);
    }
  }

  async function saveEdit() {
    if (!form.title) {
      showToast("Challenge title is required", "error");
      return;
    }
    setIsSaving(true);
    try {
      const payload = {
        title: form.title,
        description: form.description,
        startDate: form.startDate ? new Date(form.startDate).toISOString() : undefined,
        endDate: form.endDate ? new Date(form.endDate).toISOString() : undefined
      };
      const updated = await AdminAPI.updateChallenge(editItem.id, payload);
      setChallenges(prev => prev.map(c => c.id === editItem.id ? mapChallenge(updated) : c));
      setEditItem(null);
      showToast("Challenge updated successfully");
    } catch (error) {
      console.error("Failed to update challenge", error);
      showToast(error.message || "Failed to update challenge", "error");
    } finally {
      setIsSaving(false);
    }
  }

  async function doDelete() {
    try {
      await AdminAPI.deleteChallenge(deleteId);
      setChallenges(prev => prev.filter(c => c.id !== deleteId));
      showToast("Challenge deleted");
    } catch (error) {
      console.error("Failed to delete challenge", error);
      showToast(error.message || "Failed to delete challenge", "error");
    } finally {
      setDeleteId(null);
    }
  }

  const filtered = challenges.filter(c => c.title?.toLowerCase().includes(search.toLowerCase()));

  if (loading) return <div style={{ color: T.muted, padding: 40, textAlign: 'center', fontSize: 13 }}>Fetching challenges from backend...</div>;

  return (
    <div style={{ display:'flex', flexDirection:'column', gap:16 }}>
      <div style={{ display:'flex', alignItems:'center', justifyContent:'space-between' }}>
        <div>
          <div style={{ fontSize:15, fontWeight:700, color:T.text }}>Community Challenges</div>
          <div style={{ fontSize:12, color:T.muted }}>Manage active events and point rewards</div>
        </div>
        <div style={{ display:'flex', gap:10 }}>
          <div style={{ position:'relative', minWidth:200 }}>
            <Search size={14} color={T.muted} style={{ position:'absolute', left:11, top:'50%', transform:'translateY(-50%)', pointerEvents:'none' }} />
            <input value={search} onChange={e=>setSearch(e.target.value)} placeholder="Search challenges…"
              style={{ width:'100%', background:T.card, border:`1px solid ${T.border}`, borderRadius:8, padding:'8px 12px 8px 34px', color:T.text, fontSize:13, outline:'none', boxSizing:'border-box' }} />
          </div>
          <Btn onClick={openAdd}><Plus size={14}/> New challenge</Btn>
        </div>
      </div>

      <div style={{ display:'grid', gridTemplateColumns:'repeat(3,1fr)', gap:14 }}>
        {filtered.map((c) => (
          <Card key={c.id} style={{ padding:20, display:'flex', flexDirection:'column', opacity:c.status==='Draft'?0.6:1 }}>
            <div style={{ display:'flex', alignItems:'center', justifyContent:'space-between', marginBottom:12 }}>
              <Badge color={statusColor[c.status]}>{c.status}</Badge>
              <div style={{ display:'flex', alignItems:'center', gap:4, fontSize:12, color:T.amber, fontWeight:700 }}>
                <Target size={14} /> {c.points} pts
              </div>
            </div>
            <div style={{ fontSize:16, fontWeight:800, color:T.text, marginBottom:6 }}>{c.title}</div>
            <div style={{ fontSize:12, color:T.muted, lineHeight:1.6, flex:1, marginBottom:16 }}>{c.description}</div>
            
            <div style={{ display:'flex', alignItems:'center', justifyContent:'space-between', padding:'10px 12px', background:T.surf, borderRadius:8, marginBottom:14 }}>
              <div style={{ display:'flex', alignItems:'center', gap:6, color:T.muted, fontSize:11 }}>
                <Calendar size={13} />
                {c.startDate ? `${c.startDate} to ${c.endDate}` : 'No dates set'}
              </div>
            </div>

            <div style={{ display:'flex', gap:8 }}>
              <Btn variant="ghost" onClick={()=>openEdit(c)} style={{ flex:1, justifyContent:'center' }}><Edit size={12}/>Edit</Btn>
              <Btn variant="danger" onClick={()=>setDeleteId(c.id)}><Trash2 size={13}/></Btn>
            </div>
          </Card>
        ))}
        {filtered.length === 0 && <div style={{ gridColumn:'1/-1', padding:40, textAlign:'center', color:T.muted, fontSize:13 }}>No challenges found (or database is empty).</div>}
      </div>

      <Modal open={showAdd || !!editItem} onClose={() => { setShowAdd(false); setEditItem(null); }} title={showAdd ? "New Challenge" : `Edit — ${editItem?.title}`} width={500}>
        <FieldRow label="Challenge Title"><Input value={form.title} onChange={e=>setForm(p=>({...p,title:e.target.value}))} placeholder="e.g. 30-Day Sugar Detox" /></FieldRow>
        <FieldRow label="Description"><Textarea value={form.description} onChange={e=>setForm(p=>({...p,description:e.target.value}))} placeholder="Explain the rules..." rows={3} /></FieldRow>
        
        <div style={{ display:'grid', gridTemplateColumns:'1fr 1fr', gap:12 }}>
          <FieldRow label="Reward Points"><Input type="number" value={form.points} onChange={e=>setForm(p=>({...p,points:e.target.value}))} placeholder="100" /></FieldRow>
          <FieldRow label="Status">
            <Select value={form.status} onChange={e=>setForm(p=>({...p,status:e.target.value}))}>
              <option>Draft</option><option>Active</option><option>Completed</option>
            </Select>
          </FieldRow>
        </div>

        <div style={{ display:'grid', gridTemplateColumns:'1fr 1fr', gap:12 }}>
          <FieldRow label="Start Date"><Input type="date" value={form.startDate} onChange={e=>setForm(p=>({...p,startDate:e.target.value}))} /></FieldRow>
          <FieldRow label="End Date"><Input type="date" value={form.endDate} onChange={e=>setForm(p=>({...p,endDate:e.target.value}))} /></FieldRow>
        </div>

        <div style={{ display:'flex', gap:10, justifyContent:'flex-end', marginTop:8 }}>
          <Btn variant="ghost" onClick={() => { setShowAdd(false); setEditItem(null); }}>Cancel</Btn>
          <Btn disabled={isSaving} onClick={showAdd ? saveAdd : saveEdit}>
            <Check size={13}/> {isSaving ? 'Saving...' : 'Save Challenge'}
          </Btn>
        </div>
      </Modal>

      <ConfirmModal open={!!deleteId} onClose={()=>setDeleteId(null)} onConfirm={doDelete} title="Delete Challenge" message="Are you sure you want to permanently delete this challenge?" danger />
    </div>
  );
}

// ─── FOOD DATABASE PAGE ───────────────────────────────────────────────────────
function FoodPage() {
  const [foods, setFoods] = useState([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [tab, setTab] = useState('All');
  const [showAdd, setShowAdd] = useState(false);
  const [editFood, setEditFood] = useState(null);
  const [deleteId, setDeleteId] = useState(null);
  const [isSaving, setIsSaving] = useState(false);
  
  const [form, setForm] = useState({ name:'', cal:'', protein:'', carbs:'', fat:'', cat:'Protein', status:'Pending' });
  const cats = ['All','Protein','Grain','Fat','Dairy','Vegetable','Legume'];

  useEffect(() => {
    fetchFoods();
  }, []);

  const mapFood = f => ({
    id: f.id || f._id,
    name: f.class_name || f.name || 'Unknown',
    cal: f.cals_per_100g || f.cal || 0,
    protein: f.protein_per_100g || f.protein || 0,
    carbs: f.carbs_per_100g || f.carbs || 0,
    fat: f.fats_per_100g || f.fat || 0,
    cat: 'Protein',
    status: f.isVerified ? 'Approved' : 'Pending'
  });

  const payloadFromForm = (f) => ({
    class_name: f.name,
    cals_per_100g: parseFloat(f.cal) || 0,
    protein_per_100g: parseFloat(f.protein) || 0,
    carbs_per_100g: parseFloat(f.carbs) || 0,
    fats_per_100g: parseFloat(f.fat) || 0,
    isVerified: f.status === 'Approved',
    source: 'Local'
  });

  async function fetchFoods() {
    try {
      setLoading(true);
      const res = await AdminAPI.getFoods();
      const raw = Array.isArray(res) ? res : (res.data || []);
      setFoods(raw.map(mapFood));
    } catch (error) {
      console.error("API fetch failed.", error);
      showToast(error.message || "Failed to load food database", "error");
      setFoods([]);
    } finally {
      setLoading(false);
    }
  }

  const filtered = foods.filter(f =>
    (tab === 'All' || f.cat === tab) &&
    f.name?.toLowerCase().includes(search.toLowerCase())
  );

  function openAdd() { setForm({ name:'', cal:'', protein:'', carbs:'', fat:'', cat:'Protein', status:'Pending' }); setShowAdd(true); }
  function openEdit(f) { setForm({ name:f.name, cal:String(f.cal), protein:String(f.protein), carbs:String(f.carbs), fat:String(f.fat), cat:f.cat, status:f.status }); setEditFood(f); }

  async function saveAdd() {
    if (!form.name) {
      showToast("Food name is required", "error");
      return;
    }
    setIsSaving(true);
    try {
      const newFood = await AdminAPI.createFood(payloadFromForm(form));
      setFoods(prev => [...prev, mapFood(newFood)]);
      setShowAdd(false);
      showToast("Food created successfully");
    } catch (error) {
      console.error("Failed to create food item", error);
      showToast(error.message || "Failed to create food", "error");
    } finally {
      setIsSaving(false);
    }
  }

  async function saveEdit() {
    if (!form.name) {
      showToast("Food name is required", "error");
      return;
    }
    setIsSaving(true);
    try {
      const updated = await AdminAPI.updateFood(editFood.id, payloadFromForm(form));
      setFoods(prev => prev.map(f => f.id === editFood.id ? mapFood(updated) : f));
      setEditFood(null);
      showToast("Food updated successfully");
    } catch (error) {
      console.error("Failed to update food item", error);
      showToast(error.message || "Failed to update food", "error");
    } finally {
      setIsSaving(false);
    }
  }

  async function approveFood(id) {
    try {
      const target = foods.find(f => f.id === id);
      if(!target) return;
      
      const payload = {
        class_name: target.name,
        cals_per_100g: parseFloat(target.cal) || 0,
        protein_per_100g: parseFloat(target.protein) || 0,
        carbs_per_100g: parseFloat(target.carbs) || 0,
        fats_per_100g: parseFloat(target.fat) || 0,
        isVerified: true,
        source: 'Local'
      };

      const updated = await AdminAPI.updateFood(id, payload);
      setFoods(prev => prev.map(f => f.id === id ? mapFood(updated) : f));
      showToast("Food approved successfully");
    } catch (error) {
      console.error("Failed to approve food", error);
      showToast(error.message || "Failed to approve food", "error");
    }
  }

  async function doDelete() {
    try {
      await AdminAPI.deleteFood(deleteId);
      setFoods(prev => prev.filter(f => f.id !== deleteId));
      showToast("Food deleted");
    } catch (error) {
      console.error("Failed to delete food", error);
      showToast(error.message || "Failed to delete food", "error");
    } finally {
      setDeleteId(null);
    }
  }

  if (loading) return <div style={{ color: T.muted, padding: 40, textAlign: 'center', fontSize: 13 }}>Fetching food database from backend...</div>;

  return (
    <div style={{ display:'flex', flexDirection:'column', gap:16 }}>
      <div style={{ display:'flex', alignItems:'center', gap:10 }}>
        <div style={{ position:'relative', flex:1 }}>
          <Search size={14} color={T.muted} style={{ position:'absolute', left:11, top:'50%', transform:'translateY(-50%)', pointerEvents:'none' }} />
          <input value={search} onChange={e=>setSearch(e.target.value)} placeholder="Search food database…"
            style={{ width:'100%', background:T.card, border:`1px solid ${T.border}`, borderRadius:8, padding:'8px 12px 8px 34px', color:T.text, fontSize:13, outline:'none', boxSizing:'border-box' }} />
        </div>
        <Btn onClick={openAdd}><Plus size={14}/> Add food</Btn>
      </div>
      <div style={{ display:'flex', gap:6, flexWrap:'wrap' }}>
        {cats.map(c => (
          <button key={c} onClick={()=>setTab(c)} style={{ padding:'5px 12px', borderRadius:20, fontSize:11, cursor:'pointer', fontWeight:600, background:tab===c?(catColor[c]||T.green):T.card, color:tab===c?'#000':T.muted, border:`1px solid ${tab===c?(catColor[c]||T.green):T.border}` }}>{c}</button>
        ))}
      </div>
      <div style={{ display:'grid', gridTemplateColumns:'repeat(2,1fr)', gap:14 }}>
        {filtered.map((f) => (
          <Card key={f.id} style={{ padding:18 }}>
            <div style={{ display:'flex', alignItems:'flex-start', justifyContent:'space-between', marginBottom:12 }}>
              <div>
                <div style={{ fontSize:13, fontWeight:600, color:T.text, marginBottom:4 }}>{f.name}</div>
                <Badge color={catColor[f.cat]||T.muted}>{f.cat}</Badge>
              </div>
              <Badge color={f.status==='Approved'?T.green:T.amber}>{f.status}</Badge>
            </div>
            <div style={{ display:'grid', gridTemplateColumns:'repeat(4,1fr)', gap:8 }}>
              {[{l:'Kcal',v:f.cal,c:T.red},{l:'Protein',v:`${f.protein}g`,c:T.blue},{l:'Carbs',v:`${f.carbs}g`,c:T.amber},{l:'Fat',v:`${f.fat}g`,c:T.green}].map((m,j)=>(
                <div key={j} style={{ textAlign:'center', background:T.surf, borderRadius:8, padding:'9px 4px' }}>
                  <div style={{ fontSize:14, fontWeight:800, color:m.c }}>{m.v || 0}</div>
                  <div style={{ fontSize:10, color:T.muted, marginTop:2 }}>{m.l}</div>
                </div>
              ))}
            </div>
            <div style={{ display:'flex', gap:8, marginTop:12 }}>
              <Btn variant="ghost" onClick={()=>openEdit(f)} style={{ flex:1, justifyContent:'center' }}><Edit size={12}/>Edit</Btn>
              {f.status==='Pending' && <Btn variant="success" onClick={()=>approveFood(f.id)} style={{ flex:1, justifyContent:'center' }}><Check size={12}/>Approve</Btn>}
              <Btn variant="danger" onClick={()=>setDeleteId(f.id)}><Trash2 size={13}/></Btn>
            </div>
          </Card>
        ))}
        {filtered.length === 0 && <div style={{ gridColumn:'1/-1', padding:40, textAlign:'center', color:T.muted, fontSize:13 }}>No food items found (or database is empty).</div>}
      </div>

      <Modal open={showAdd} onClose={()=>setShowAdd(false)} title="Add food item" width={520}>
        <FoodForm form={form} setForm={setForm} onSave={saveAdd} isSaving={isSaving} onCancel={()=>setShowAdd(false)} cats={cats} />
      </Modal>
      <Modal open={!!editFood} onClose={()=>setEditFood(null)} title={`Edit — ${editFood?.name}`} width={520}>
        <FoodForm form={form} setForm={setForm} onSave={saveEdit} isSaving={isSaving} onCancel={()=>setEditFood(null)} cats={cats} />
      </Modal>
      <ConfirmModal open={!!deleteId} onClose={()=>setDeleteId(null)} onConfirm={doDelete}
        title="Delete food item" message="Remove this food item from the database permanently?" danger />
    </div>
  );
}

// ─── STATIC UI PLACEHOLDERS ───────────────────────────────────────────────────
function PlansPage() { return <div style={{color:T.muted, padding:40, textAlign:'center'}}>Plans API not linked yet.</div>; }
function AnalyticsPage() { return <div style={{color:T.muted, padding:40, textAlign:'center'}}>Analytics API not linked yet.</div>; }
function NotificationsPage() { return <div style={{color:T.muted, padding:40, textAlign:'center'}}>Notifications API not linked yet.</div>; }
function ContentPage() { return <div style={{color:T.muted, padding:40, textAlign:'center'}}>Content API not linked yet.</div>; }
function SecurityPage() { return <div style={{color:T.muted, padding:40, textAlign:'center'}}>Security Module not linked yet.</div>; }
function SettingsPage({ adminProfile, setAdminProfile }) {
  const [form, setForm] = useState({
    name: adminProfile?.name || '',
    age: adminProfile?.age ? String(adminProfile.age) : '',
    phone: adminProfile?.phone || '',
    height: adminProfile?.height ? String(adminProfile.height) : '',
    weight: adminProfile?.weight ? String(adminProfile.weight) : '',
    gender: adminProfile?.gender || 'Male',
    activityLevel: adminProfile?.activityLevel || 'Sedentary',
    userGoal: adminProfile?.userGoal || 'Maintain Weight',
    notificationsEnabled: adminProfile?.notificationsEnabled || false
  });
  const [isSaving, setIsSaving] = useState(false);

  if (!adminProfile) {
    return <div style={{ color: T.muted, padding: 40, textAlign: 'center' }}>No profile details loaded.</div>;
  }

  const handleSave = async (e) => {
    e.preventDefault();
    if (!form.name) {
      showToast('Name is required', 'error');
      return;
    }

    setIsSaving(true);
    try {
      const payload = {
        name: form.name,
        age: form.age ? parseInt(form.age, 10) : null,
        phone: form.phone || null,
        height: form.height ? parseFloat(form.height) : null,
        weight: form.weight ? parseFloat(form.weight) : null,
        gender: form.gender,
        activityLevel: form.activityLevel,
        userGoal: form.userGoal,
        notificationsEnabled: form.notificationsEnabled
      };

      const res = await AdminAPI.updateUser(adminProfile.id, payload);
      const updatedUser = res.user || res.data || res;

      const merged = { ...adminProfile, ...updatedUser };
      setAdminProfile(merged);
      localStorage.setItem('admin_profile', JSON.stringify(merged));
      showToast('Profile updated successfully!');
    } catch (err) {
      console.error('Failed to update admin profile:', err);
      showToast(err.message || 'Failed to update profile details', 'error');
    } finally {
      setIsSaving(false);
    }
  };

  const getInitials = (name) => {
    if (!name) return 'AD';
    return name.split(' ').map(n => n[0]).join('').toUpperCase().substring(0, 2);
  };

  return (
    <div style={{ display: 'grid', gridTemplateColumns: '1fr 2fr', gap: 20, alignItems: 'start' }}>
      <Card style={{ padding: 24, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 16 }}>
        <div style={{ width: 80, height: 80, borderRadius: '50%', background: T.glow, border: `2.5px solid ${T.green}50`, display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 24, fontWeight: 800, color: T.green }}>
          {getInitials(adminProfile.name)}
        </div>
        <div style={{ textAlign: 'center' }}>
          <div style={{ fontSize: 16, fontWeight: 700, color: T.text }}>{adminProfile.name}</div>
          <div style={{ fontSize: 12, color: T.muted, marginTop: 4 }}>{adminProfile.role || 'Admin'}</div>
        </div>

        <div style={{ width: '100%', borderTop: `1px solid ${T.border}`, paddingTop: 16, display: 'flex', flexDirection: 'column', gap: 12 }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: 12 }}>
            <span style={{ color: T.muted }}>Email</span>
            <span style={{ color: T.text, fontWeight: 500 }}>{adminProfile.email}</span>
          </div>
          <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: 12 }}>
            <span style={{ color: T.muted }}>Age</span>
            <span style={{ color: T.text, fontWeight: 500 }}>{adminProfile.age || 'Not set'}</span>
          </div>
          <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: 12 }}>
            <span style={{ color: T.muted }}>XP Level</span>
            <span style={{ color: T.green, fontWeight: 700 }}>{adminProfile.xp || 0} XP</span>
          </div>
          <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: 12 }}>
            <span style={{ color: T.muted }}>Account ID</span>
            <span style={{ color: T.muted, fontSize: 10, fontFamily: 'monospace', maxWidth: 180, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }} title={adminProfile.id}>
              {adminProfile.id}
            </span>
          </div>
          <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: 12 }}>
            <span style={{ color: T.muted }}>Joined</span>
            <span style={{ color: T.text, fontWeight: 500 }}>
              {adminProfile.createdAt ? new Date(adminProfile.createdAt).toLocaleDateString() : 'Unknown'}
            </span>
          </div>
        </div>
      </Card>

      <Card style={{ padding: 24 }}>
        <h2 style={{ fontSize: 15, fontWeight: 700, color: T.text, margin: '0 0 20px 0' }}>Profile Details</h2>
        <form onSubmit={handleSave} style={{ display: 'flex', flexDirection: 'column', gap: 16 }}>
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(2, 1fr)', gap: 16 }}>
            <FieldRow label="Full Name">
              <Input value={form.name} onChange={e => setForm(prev => ({ ...prev, name: e.target.value }))} placeholder="Mohamed Atta" />
            </FieldRow>
            <FieldRow label="Phone Number">
              <Input value={form.phone} onChange={e => setForm(prev => ({ ...prev, phone: e.target.value }))} placeholder="+20123456789" />
            </FieldRow>
          </div>

          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: 16 }}>
            <FieldRow label="Age (Years)">
              <Input type="number" value={form.age} onChange={e => setForm(prev => ({ ...prev, age: e.target.value }))} placeholder="22" />
            </FieldRow>
            <FieldRow label="Height (cm)">
              <Input type="number" value={form.height} onChange={e => setForm(prev => ({ ...prev, height: e.target.value }))} placeholder="175" />
            </FieldRow>
            <FieldRow label="Weight (kg)">
              <Input type="number" value={form.weight} onChange={e => setForm(prev => ({ ...prev, weight: e.target.value }))} placeholder="70" />
            </FieldRow>
          </div>

          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: 16 }}>
            <FieldRow label="Gender">
              <Select value={form.gender} onChange={e => setForm(prev => ({ ...prev, gender: e.target.value }))}>
                <option value="Male">Male</option>
                <option value="Female">Female</option>
              </Select>
            </FieldRow>
            <FieldRow label="Activity Level">
              <Select value={form.activityLevel} onChange={e => setForm(prev => ({ ...prev, activityLevel: e.target.value }))}>
                <option value="Sedentary">Sedentary</option>
                <option value="Lightly Active">Lightly Active</option>
                <option value="Moderately Active">Moderately Active</option>
                <option value="Very Active">Very Active</option>
                <option value="Extra Active">Extra Active</option>
              </Select>
            </FieldRow>
            <FieldRow label="User Goal">
              <Select value={form.userGoal} onChange={e => setForm(prev => ({ ...prev, userGoal: e.target.value }))}>
                <option value="Lose Weight">Lose Weight</option>
                <option value="Gain Weight">Gain Weight</option>
                <option value="Maintain Weight">Maintain Weight</option>
              </Select>
            </FieldRow>
          </div>

          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '12px 16px', background: T.surf, borderRadius: 8, border: `1px solid ${T.border}`, marginTop: 8 }}>
            <div>
              <div style={{ fontSize: 13, fontWeight: 600, color: T.text }}>Push Notifications</div>
              <div style={{ fontSize: 11, color: T.muted, marginTop: 2 }}>Receive notifications about community changes & logs</div>
            </div>
            <input type="checkbox" checked={form.notificationsEnabled} onChange={e => setForm(prev => ({ ...prev, notificationsEnabled: e.target.checked }))}
              style={{ width: 18, height: 18, accentColor: T.green, cursor: 'pointer' }} />
          </div>

          <div style={{ display: 'flex', justifyContent: 'flex-end', marginTop: 12 }}>
            <Btn type="submit" disabled={isSaving}>
              {isSaving ? 'Saving Changes...' : 'Save Settings'}
            </Btn>
          </div>
        </form>
      </Card>
    </div>
  );
}

const pageMap = {
  dashboard:    DashboardPage,
  users:        UsersPage,
  foods:        FoodPage,
  plans:        PlansPage,
  challenges:   ChallengesPage,
  analytics:    AnalyticsPage,
  notifications:NotificationsPage,
  content:      ContentPage,
  security:     SecurityPage,
  settings:     SettingsPage,
};

// ─── ADMIN LOGIN SCREEN ───────────────────────────────────────────────────────
function AdminLoginScreen({ onLoginSuccess }) {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!email || !password) {
      showToast('Please fill in all fields', 'error');
      return;
    }
    
    if (!/\S+@\S+\.\S+/.test(email)) {
      showToast('Please enter a valid email address', 'error');
      return;
    }

    setLoading(true);
    try {
      const res = await AdminAPI.login(email, password);
      if (res && res.success && res.data) {
        showToast('Logged in successfully!', 'success');
        onLoginSuccess(res.data.token, res.data.admin);
      } else {
        showToast(res.message || 'Login failed', 'error');
      }
    } catch (err) {
      console.error('Login error:', err);
      showToast(err.message || 'Invalid email or password', 'error');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div style={{ display: 'flex', height: '100vh', width: '100vw', alignItems: 'center', justifyContent: 'center', background: T.bg, fontFamily: 'system-ui,-apple-system,BlinkMacSystemFont,sans-serif' }}>
      <div style={{ width: 380, padding: 32, background: T.surf, border: `1px solid ${T.border}`, borderRadius: 16, boxShadow: '0 10px 30px rgba(0,0,0,0.5)', display: 'flex', flexDirection: 'column', gap: 24 }}>
        <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 10 }}>
          <div style={{ width: 44, height: 44, borderRadius: 12, background: T.green, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <Leaf size={24} color="#000" />
          </div>
          <div style={{ textAlign: 'center' }}>
            <h1 style={{ fontSize: 20, fontWeight: 800, color: T.text, margin: 0 }}>Bite Smart</h1>
            <p style={{ fontSize: 12, color: T.muted, margin: '4px 0 0 0', textTransform: 'uppercase', letterSpacing: '0.08em' }}>Admin Console</p>
          </div>
        </div>

        <form onSubmit={handleSubmit} style={{ display: 'flex', flexDirection: 'column', gap: 16 }}>
          <FieldRow label="Admin Email">
            <Input type="email" value={email} onChange={e => setEmail(e.target.value)} placeholder="admin@example.com" />
          </FieldRow>
          <FieldRow label="Password">
            <Input type="password" value={password} onChange={e => setPassword(e.target.value)} placeholder="••••••••" />
          </FieldRow>

          <Btn type="submit" disabled={loading} style={{ width: '100%', justifyContent: 'center', height: 40, marginTop: 8 }}>
            {loading ? 'Authenticating...' : 'Sign In'}
          </Btn>
        </form>
      </div>
    </div>
  );
}

export default function BiteSmart() {
  const [token, setToken] = useState(() => localStorage.getItem('admin_token'));
  const [adminProfile, setAdminProfile] = useState(() => {
    const saved = localStorage.getItem('admin_profile');
    try {
      return saved ? JSON.parse(saved) : null;
    } catch(e) {
      return null;
    }
  });

  const [page, setPage] = useState('dashboard');
  const [collapsed, setCollapsed] = useState(false);

  useEffect(() => {
    const handleAuthError = () => {
      setToken(null);
      setAdminProfile(null);
    };
    window.addEventListener('unauthorized_access', handleAuthError);
    return () => {
      window.removeEventListener('unauthorized_access', handleAuthError);
    };
  }, []);

  const handleLoginSuccess = async (newToken, newAdmin) => {
    localStorage.setItem('admin_token', newToken);
    setToken(newToken);

    let fullAdmin = newAdmin;
    try {
      const fetched = await AdminAPI.getUserById(newAdmin.id);
      if (fetched) {
        fullAdmin = fetched.user || fetched.data || fetched;
      }
    } catch (err) {
      console.error("Failed to fetch full admin profile details on login, falling back to login payload:", err);
    }

    localStorage.setItem('admin_profile', JSON.stringify(fullAdmin));
    setAdminProfile(fullAdmin);
    setPage('dashboard');
  };

  const handleSignOut = () => {
    localStorage.removeItem('admin_token');
    localStorage.removeItem('admin_profile');
    setToken(null);
    setAdminProfile(null);
    showToast('Logged out successfully', 'success');
  };

  if (!token) {
    return (
      <>
        <AdminLoginScreen onLoginSuccess={handleLoginSuccess} />
        <ToastContainer />
      </>
    );
  }

  const PageComponent = pageMap[page];

  const getInitials = (name) => {
    if (!name) return 'AD';
    return name.split(' ').map(n => n[0]).join('').toUpperCase().substring(0, 2);
  };

  const initials = adminProfile ? getInitials(adminProfile.name) : 'AD';

  return (
    <div style={{ display:'flex', height:'100vh', overflow:'hidden', background:T.bg, color:T.text, fontFamily:'system-ui,-apple-system,BlinkMacSystemFont,sans-serif' }}>
      
      {/* Sidebar */}
      <aside style={{ width:collapsed?58:218, flexShrink:0, background:T.surf, borderRight:`1px solid ${T.border}`, display:'flex', flexDirection:'column', transition:'width .22s cubic-bezier(.4,0,.2,1)', overflow:'hidden' }}>
        <div style={{ padding:'16px 12px', borderBottom:`1px solid ${T.border}`, display:'flex', alignItems:'center', gap:10, minHeight:58 }}>
          <div style={{ width:32, height:32, borderRadius:9, background:T.green, display:'flex', alignItems:'center', justifyContent:'center', flexShrink:0 }}>
            <Leaf size={16} color="#000" />
          </div>
          {!collapsed && (
            <div>
              <div style={{ fontSize:13, fontWeight:800, color:T.text, lineHeight:1.2, whiteSpace:'nowrap' }}>Bite Smart</div>
              <div style={{ fontSize:9, color:T.muted, textTransform:'uppercase', letterSpacing:'0.08em' }}>Admin Console</div>
            </div>
          )}
        </div>

        <nav style={{ flex:1, padding:'10px 8px', overflowY:'auto', overflowX:'hidden' }}>
          {navItems.map(item => {
            const active = page === item.id;
            return (
              <button key={item.id} onClick={()=>setPage(item.id)} style={{ width:'100%', display:'flex', alignItems:'center', gap:10, padding:collapsed?'10px 13px':'9px 11px', borderRadius:8, marginBottom:2, background:active?`${T.green}1c`:'none', border:`1px solid ${active?T.green+'40':'transparent'}`, color:active?T.green:T.muted, cursor:'pointer', textAlign:'left', fontSize:13, fontWeight:active?700:400, whiteSpace:'nowrap', overflow:'hidden', justifyContent:collapsed?'center':'flex-start', transition:'background .15s, color .15s', position:'relative' }}
                onMouseEnter={e=>{ if(!active){e.currentTarget.style.background=T.dim+'60';e.currentTarget.style.color=T.text;}}}
                onMouseLeave={e=>{ if(!active){e.currentTarget.style.background='none';e.currentTarget.style.color=T.muted;}}}>
                <item.Icon size={16} style={{ flexShrink:0 }} />
                {!collapsed && <span>{item.label}</span>}
              </button>
            );
          })}
        </nav>

        <div style={{ padding:'10px 8px', borderTop:`1px solid ${T.border}` }}>
          {!collapsed && adminProfile && (
            <div style={{ display:'flex', alignItems:'center', gap:9, padding:'8px 10px', borderRadius:8, marginBottom:4 }}>
              <div style={{ width:28, height:28, borderRadius:'50%', background:T.glow, border:`1.5px solid ${T.green}40`, display:'flex', alignItems:'center', justifyContent:'center', fontSize:10, fontWeight:800, color:T.green, flexShrink:0 }}>
                {initials}
              </div>
              <div style={{ overflow:'hidden' }}>
                <div style={{ fontSize:12, fontWeight:600, color:T.text, lineHeight:1.2, whiteSpace:'nowrap', overflow:'hidden', textOverflow:'ellipsis' }}>{adminProfile.name}</div>
                <div style={{ fontSize:10, color:T.muted, whiteSpace:'nowrap', overflow:'hidden', textOverflow:'ellipsis' }}>{adminProfile.role || 'Admin'}</div>
              </div>
            </div>
          )}
          <button onClick={handleSignOut} style={{ width:'100%', display:'flex', alignItems:'center', gap:10, padding:collapsed?'10px 13px':'8px 11px', borderRadius:8, background:'none', border:'1px solid transparent', color:T.muted, cursor:'pointer', fontSize:12, justifyContent:collapsed?'center':'flex-start' }}
            onMouseEnter={e=>{e.currentTarget.style.color=T.red;}}
            onMouseLeave={e=>{e.currentTarget.style.color=T.muted;}}>
            <LogOut size={15} style={{ flexShrink:0 }} />
            {!collapsed && 'Sign out'}
          </button>
        </div>
      </aside>

      {/* Main Content Area */}
      <div style={{ flex:1, display:'flex', flexDirection:'column', overflow:'hidden' }}>
        <header style={{ padding:'0 22px', height:56, flexShrink:0, borderBottom:`1px solid ${T.border}`, background:T.surf, display:'flex', alignItems:'center', gap:14, zIndex:10 }}>
          <button onClick={()=>setCollapsed(v=>!v)} style={{ background:'none', border:'none', cursor:'pointer', color:T.muted, padding:6, borderRadius:7, display:'flex', alignItems:'center' }}
            onMouseEnter={e=>e.currentTarget.style.background=T.dim}
            onMouseLeave={e=>e.currentTarget.style.background='none'}>
            <Menu size={18} />
          </button>
          <div style={{ fontSize:15, fontWeight:700, color:T.text, flex:1 }}>{pageLabels[page]}</div>
          <div style={{ display:'flex', alignItems:'center', gap:6, fontSize:11, color:T.muted }}>
            <span style={{ color:T.green }}>Bite Smart</span>
            <ChevronRight size={12} />
            <span>{pageLabels[page]}</span>
          </div>
          <div style={{ position:'relative' }}>
            <Search size={13} color={T.muted} style={{ position:'absolute', left:10, top:'50%', transform:'translateY(-50%)', pointerEvents:'none' }} />
            <input placeholder="Quick search… (⌘K)" style={{ background:T.card, border:`1px solid ${T.border}`, borderRadius:8, padding:'6px 12px 6px 30px', color:T.text, fontSize:12, outline:'none', width:200 }} />
          </div>
          <button onClick={()=>setPage('notifications')} style={{ position:'relative', background:'none', border:'none', cursor:'pointer', color:T.muted, padding:6 }}>
            <Bell size={18} />
          </button>
          <div style={{ width:33, height:33, borderRadius:'50%', background:T.glow, border:`2px solid ${T.green}50`, display:'flex', alignItems:'center', justifyContent:'center', fontSize:11, fontWeight:800, color:T.green, flexShrink:0 }}>
            {initials}
          </div>
        </header>

        <main style={{ flex:1, overflowY:'auto', padding:24, background:T.bg }}>
          <PageComponent adminProfile={adminProfile} setAdminProfile={setAdminProfile} />
        </main>
      </div>
      <ToastContainer />
    </div>
  );
}