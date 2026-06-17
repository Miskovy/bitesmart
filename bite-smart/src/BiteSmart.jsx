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
  CheckCircle, XCircle,
} from "lucide-react";

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

// ─── Data ─────────────────────────────────────────────────────────────────────
const areaData = Array.from({ length: 30 }, (_, i) => ({
  day: String(i + 1),
  users: Math.floor(7800 + Math.sin(i / 5) * 600 + i * 90 + (i * 37 % 280)),
  meals: Math.floor(11200 + Math.cos(i / 4) * 900 + i * 170 + (i * 53 % 420)),
}));

const barData = [
  { day: 'Mon', logs: 1842 }, { day: 'Tue', logs: 2105 },
  { day: 'Wed', logs: 1930 }, { day: 'Thu', logs: 2388 },
  { day: 'Fri', logs: 2100 }, { day: 'Sat', logs: 1650 },
  { day: 'Sun', logs: 1420 },
];

const pieData = [{ name: 'Free', v: 58 }, { name: 'Pro', v: 31 }, { name: 'Family', v: 11 }];
const pieClrs = [T.dim, T.green, T.greenL];

const initialUsers = [
  { id:1,  name:'Amira Hassan',   email:'amira@gmail.com',   plan:'Pro',    status:'Active',   meals:847,  joined:'Jan 2025', country:'Egypt',   verified:true  },
  { id:2,  name:'Karim Nour',     email:'karim@gmail.com',   plan:'Free',   status:'Active',   meals:234,  joined:'Feb 2025', country:'Egypt',   verified:true  },
  { id:3,  name:'Sara El-Din',    email:'sara@gmail.com',    plan:'Family', status:'Active',   meals:1204, joined:'Feb 2025', country:'UAE',     verified:true  },
  { id:4,  name:'Mohamed Ali',    email:'mo@gmail.com',      plan:'Pro',    status:'Active',   meals:621,  joined:'Mar 2025', country:'Egypt',   verified:false },
  { id:5,  name:'Layla Farouk',   email:'layla@gmail.com',   plan:'Free',   status:'Inactive', meals:88,   joined:'Mar 2025', country:'Jordan',  verified:false },
  { id:6,  name:'Ahmed Samir',    email:'ahmed@gmail.com',   plan:'Pro',    status:'Active',   meals:973,  joined:'Apr 2025', country:'Egypt',   verified:true  },
  { id:7,  name:'Nada Ibrahim',   email:'nada@gmail.com',    plan:'Family', status:'Active',   meals:1560, joined:'Apr 2025', country:'Lebanon', verified:true  },
  { id:8,  name:'Omar Khalil',    email:'omar@gmail.com',    plan:'Free',   status:'Active',   meals:302,  joined:'Apr 2025', country:'Egypt',   verified:true  },
  { id:9,  name:'Rania Mostafa',  email:'rania@gmail.com',   plan:'Pro',    status:'Active',   meals:710,  joined:'May 2025', country:'UAE',     verified:true  },
  { id:10, name:'Youssef Adel',   email:'youssef@gmail.com', plan:'Free',   status:'Active',   meals:189,  joined:'May 2025', country:'Egypt',   verified:false },
];

const initialFoods = [
  { id:1, name:'Grilled Chicken Breast', cal:165, protein:31,  carbs:0,  fat:3.6,  cat:'Protein',   status:'Approved', logs:2340 },
  { id:2, name:'Brown Rice (1 cup)',      cal:216, protein:5,   carbs:45, fat:1.8,  cat:'Grain',     status:'Approved', logs:1890 },
  { id:3, name:'Avocado (half)',          cal:120, protein:1.5, carbs:6,  fat:11,   cat:'Fat',       status:'Approved', logs:1540 },
  { id:4, name:'Greek Yogurt',           cal:100, protein:17,  carbs:6,  fat:0.7,  cat:'Dairy',     status:'Approved', logs:980  },
  { id:5, name:'Sweet Potato',           cal:103, protein:2.3, carbs:24, fat:0.1,  cat:'Vegetable', status:'Approved', logs:1120 },
  { id:6, name:'Salmon Fillet (100g)',   cal:208, protein:28,  carbs:0,  fat:10,   cat:'Protein',   status:'Pending',  logs:0    },
  { id:7, name:'Broccoli (1 cup)',       cal:55,  protein:3.7, carbs:11, fat:0.6,  cat:'Vegetable', status:'Approved', logs:870  },
  { id:8, name:'Ful Medames',            cal:187, protein:9,   carbs:29, fat:3.2,  cat:'Legume',    status:'Pending',  logs:0    },
];

const initialPlans = [
  { id:1, name:'Clean Bulk',         goal:'Muscle Gain',  kcal:2800, users:1240, tag:'Popular',    color:T.blue,   active:true,  desc:'High protein, moderate carbs, steady surplus for clean gains.' },
  { id:2, name:'Mediterranean Cut',  goal:'Weight Loss',  kcal:1600, users:3580, tag:'Best Seller',color:T.green,  active:true,  desc:'Heart-healthy Mediterranean foods with a gentle calorie deficit.' },
  { id:3, name:'Keto Reset',         goal:'Fat Loss',     kcal:1800, users:892,  tag:'New',         color:T.amber,  active:true,  desc:'Ultra-low carb, high fat protocol to switch to fat-burning mode.' },
  { id:4, name:'Athlete Fuel',       goal:'Performance',  kcal:3200, users:445,  tag:'Pro Only',    color:T.purple, active:true,  desc:'High-carb periodized nutrition for competitive sport training.' },
  { id:5, name:'Gentle Balance',     goal:'Maintenance',  kcal:2000, users:2100, tag:'Beginner',    color:T.greenL, active:true,  desc:'Balanced macros designed for those starting their health journey.' },
  { id:6, name:'Ramadan Plan',       goal:'Fasting',      kcal:1900, users:760,  tag:'Seasonal',    color:T.amber,  active:false, desc:'Optimized suhoor & iftar meals for energy during fasting hours.' },
];

const initialNotifications = [
  { id:1, type:'user',    title:'New user registered',       body:'Amira Hassan just created an account.',       time:'just now',    read:false, priority:'normal' },
  { id:2, type:'food',    title:'Food item needs review',    body:'Ful Medames submitted for approval.',          time:'2 min ago',   read:false, priority:'normal' },
  { id:3, type:'security',title:'Security audit completed',  body:'All 14 checks passed. No issues found.',      time:'15 min ago',  read:false, priority:'low'    },
  { id:4, type:'billing', title:'New Pro subscription',      body:'Karim Nour upgraded to Pro plan.',            time:'1 hr ago',    read:true,  priority:'normal' },
  { id:5, type:'alert',   title:'Failed payment retry',      body:'User #4821 – 3rd retry failed. Requires attention.', time:'2 hr ago', read:true, priority:'high' },
  { id:6, type:'content', title:'Article published',         body:'Ramadan Nutrition Guide is now live.',        time:'3 hr ago',    read:true,  priority:'low'    },
  { id:7, type:'user',    title:'Account deactivated',       body:'User Layla Farouk marked inactive.',          time:'5 hr ago',    read:true,  priority:'normal' },
  { id:8, type:'alert',   title:'CPU spike detected',        body:'API server at 94% CPU for 3 minutes.',       time:'6 hr ago',    read:true,  priority:'high'   },
  { id:9, type:'billing', title:'Refund processed',          body:'$9.99 refunded to sara@gmail.com.',           time:'Yesterday',   read:true,  priority:'normal' },
  { id:10,type:'security',title:'New admin login detected',  body:'Login from Cairo, Egypt (admin@bitesmart.app).','time':'Yesterday', read:true,  priority:'normal' },
];

const initialContent = [
  { id:1,  title:'10 Best High-Protein Breakfasts',     type:'Article',  status:'Published', author:'Admin',      views:4820, date:'May 10', tags:['nutrition','protein'] },
  { id:2,  title:'Ramadan Nutrition Guide 2025',        type:'Article',  status:'Published', author:'Dr. Hana M', views:12400,date:'Mar 29', tags:['ramadan','fasting'] },
  { id:3,  title:'Getting Started with Calorie Tracking',type:'Guide',   status:'Published', author:'Admin',      views:6310, date:'Feb 15', tags:['beginner','tracking'] },
  { id:4,  title:'Keto vs Mediterranean: Which Wins?',  type:'Article',  status:'Draft',     author:'Admin',      views:0,    date:'May 18', tags:['keto','diet'] },
  { id:5,  title:'Weekly Meal Prep for Busy Families',  type:'Recipe',   status:'Published', author:'Chef Leila', views:3190, date:'Apr 2',  tags:['meal-prep','family'] },
  { id:6,  title:'Understanding Macros 101',            type:'Guide',    status:'Draft',     author:'Admin',      views:0,    date:'May 19', tags:['macros','education'] },
  { id:7,  title:'Top 5 Egyptian Healthy Foods',        type:'Article',  status:'Review',    author:'Admin',      views:0,    date:'May 17', tags:['egypt','local'] },
  { id:8,  title:'Post-Workout Nutrition Tips',         type:'Article',  status:'Published', author:'Dr. Hana M', views:2870, date:'Apr 20', tags:['workout','recovery'] },
];

const catColor = { Protein:T.blue, Grain:T.amber, Fat:T.green, Dairy:T.purple, Vegetable:T.greenL, Legume:T.amber };

const navItems = [
  { id:'dashboard',     label:'Dashboard',     Icon:LayoutDashboard },
  { id:'users',         label:'Users',         Icon:Users            },
  { id:'foods',         label:'Food Database', Icon:Apple            },
  { id:'plans',         label:'Meal Plans',    Icon:ClipboardList    },
  { id:'analytics',     label:'Analytics',     Icon:BarChart2        },
  { id:'notifications', label:'Notifications', Icon:Bell             },
  { id:'content',       label:'Content',       Icon:FileText         },
  { id:'security',      label:'Security',      Icon:Shield           },
  { id:'settings',      label:'Settings',      Icon:Settings         },
];

const pageLabels = {
  dashboard:'Dashboard', users:'User Management', foods:'Food Database',
  plans:'Meal Plans', analytics:'Analytics', notifications:'Notifications',
  content:'Content', security:'Security', settings:'Settings',
};

// ─── Utilities ────────────────────────────────────────────────────────────────
function uid() { return Date.now() + Math.floor(Math.random() * 1000); }

// ─── Shared UI ────────────────────────────────────────────────────────────────
function Card({ children, style = {}, onClick }) {
  return (
    <div onClick={onClick} style={{ background:T.card, border:`1px solid ${T.border}`, borderRadius:12, ...style }}>
      {children}
    </div>
  );
}

function Badge({ children, color = T.green, bg }) {
  return (
    <span style={{ display:'inline-block', padding:'2px 10px', borderRadius:20, fontSize:11, fontWeight:600, color, background: bg || `${color}1a` }}>
      {children}
    </span>
  );
}

function Toggle({ val, onToggle }) {
  return (
    <div onClick={onToggle} style={{ width:40, height:22, borderRadius:11, background: val ? T.green : T.dim, cursor:'pointer', position:'relative', transition:'background .2s', flexShrink:0 }}>
      <div style={{ position:'absolute', top:3, left: val ? 21 : 3, width:16, height:16, borderRadius:'50%', background:'#fff', transition:'left .2s' }} />
    </div>
  );
}

function ChartTip({ active, payload, label }) {
  if (!active || !payload?.length) return null;
  return (
    <div style={{ background:T.card, border:`1px solid ${T.border}`, borderRadius:8, padding:'8px 12px', fontSize:12 }}>
      <div style={{ color:T.muted, marginBottom:4 }}>{label}</div>
      {payload.map((p, i) => (
        <div key={i} style={{ color:p.color, fontWeight:600 }}>{p.name}: {p.value?.toLocaleString()}</div>
      ))}
    </div>
  );
}

function Btn({ children, onClick, variant='primary', size='md', style={}, disabled=false }) {
  const base = { display:'flex', alignItems:'center', gap:6, borderRadius:8, cursor:disabled?'not-allowed':'pointer', fontWeight:600, border:'none', transition:'opacity .15s', opacity:disabled?0.5:1, ...style };
  const sizes = { sm:'6px 11px', md:'8px 16px', lg:'10px 22px' };
  const variants = {
    primary: { background:T.green, color:'#000', fontSize:12 },
    ghost:   { background:'none', border:`1px solid ${T.border}`, color:T.muted, fontSize:12 },
    danger:  { background:`${T.red}18`, border:`1px solid ${T.red}40`, color:T.red, fontSize:12 },
    success: { background:`${T.green}18`, border:`1px solid ${T.green}40`, color:T.green, fontSize:12 },
  };
  return (
    <button onClick={disabled?undefined:onClick} style={{ ...base, ...variants[variant], padding:sizes[size] }}>
      {children}
    </button>
  );
}

// ─── Modal ────────────────────────────────────────────────────────────────────
function Modal({ open, onClose, title, children, width=480 }) {
  useEffect(() => {
    const handler = (e) => { if (e.key === 'Escape') onClose(); };
    if (open) window.addEventListener('keydown', handler);
    return () => window.removeEventListener('keydown', handler);
  }, [open, onClose]);

  if (!open) return null;
  return (
    <div style={{ position:'fixed', inset:0, zIndex:1000, display:'flex', alignItems:'center', justifyContent:'center', background:'rgba(0,0,0,0.7)', backdropFilter:'blur(4px)' }}
      onClick={e => { if (e.target === e.currentTarget) onClose(); }}>
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
  return (
    <input type={type} value={value} onChange={onChange} placeholder={placeholder}
      style={{ width:'100%', background:T.card, border:`1px solid ${T.border}`, borderRadius:8, padding:'9px 13px', color:T.text, fontSize:13, outline:'none', boxSizing:'border-box', ...style }} />
  );
}

function Select({ value, onChange, children, style={} }) {
  return (
    <select value={value} onChange={onChange}
      style={{ width:'100%', background:T.card, border:`1px solid ${T.border}`, borderRadius:8, padding:'9px 13px', color:T.text, fontSize:13, outline:'none', boxSizing:'border-box', ...style }}>
      {children}
    </select>
  );
}

function Textarea({ value, onChange, placeholder, rows=3 }) {
  return (
    <textarea value={value} onChange={onChange} placeholder={placeholder} rows={rows}
      style={{ width:'100%', background:T.card, border:`1px solid ${T.border}`, borderRadius:8, padding:'9px 13px', color:T.text, fontSize:13, outline:'none', boxSizing:'border-box', resize:'vertical' }} />
  );
}

function UserForm({ form, setForm, onSave, saving, onCancel }) {
  return (
    <>
      <FieldRow label="Full name"><Input value={form.name} onChange={e=>setForm(p=>({...p,name:e.target.value}))} placeholder="e.g. Amira Hassan" /></FieldRow>
      <FieldRow label="Email"><Input type="email" value={form.email} onChange={e=>setForm(p=>({...p,email:e.target.value}))} placeholder="user@email.com" /></FieldRow>
      <div style={{ display:'grid', gridTemplateColumns:'1fr 1fr', gap:12 }}>
        <FieldRow label="Plan">
          <Select value={form.plan} onChange={e=>setForm(p=>({...p,plan:e.target.value}))}>
            <option>Free</option><option>Pro</option><option>Family</option>
          </Select>
        </FieldRow>
        <FieldRow label="Status">
          <Select value={form.status} onChange={e=>setForm(p=>({...p,status:e.target.value}))}>
            <option>Active</option><option>Inactive</option>
          </Select>
        </FieldRow>
      </div>
      <FieldRow label="Country"><Input value={form.country} onChange={e=>setForm(p=>({...p,country:e.target.value}))} placeholder="e.g. Egypt" /></FieldRow>
      <div style={{ display:'flex', gap:10, justifyContent:'flex-end', marginTop:8 }}>
        <Btn variant="ghost" onClick={onCancel}>Cancel</Btn>
        <Btn onClick={onSave}><Check size={13}/>{saving ? 'Add user' : 'Save changes'}</Btn>
      </div>
    </>
  );
}

function FoodForm({ form, setForm, onSave, onCancel, cats }) {
  return (
    <>
      <FieldRow label="Food name"><Input value={form.name} onChange={e=>setForm(p=>({...p,name:e.target.value}))} placeholder="e.g. Grilled Chicken Breast" /></FieldRow>
      <div style={{ display:'grid', gridTemplateColumns:'1fr 1fr', gap:12 }}>
        <FieldRow label="Category">
          <Select value={form.cat} onChange={e=>setForm(p=>({...p,cat:e.target.value}))}>
            {cats.filter(c=>c!=='All').map(c=><option key={c}>{c}</option>)}
          </Select>
        </FieldRow>
        <FieldRow label="Status">
          <Select value={form.status} onChange={e=>setForm(p=>({...p,status:e.target.value}))}>
            <option>Pending</option><option>Approved</option>
          </Select>
        </FieldRow>
      </div>
      <div style={{ display:'grid', gridTemplateColumns:'repeat(4,1fr)', gap:10 }}>
        {[['Calories (kcal)','cal'],['Protein (g)','protein'],['Carbs (g)','carbs'],['Fat (g)','fat']].map(([label,key]) => (
          <FieldRow key={key} label={label}><Input type="number" value={form[key]} onChange={e=>setForm(p=>({...p,[key]:e.target.value}))} placeholder="0" /></FieldRow>
        ))}
      </div>
      <div style={{ display:'flex', gap:10, justifyContent:'flex-end', marginTop:8 }}>
        <Btn variant="ghost" onClick={onCancel}>Cancel</Btn>
        <Btn onClick={onSave}><Check size={13}/>Save</Btn>
      </div>
    </>
  );
}

function PlanForm({ form, setForm, onSave, onCancel, goals, colors }) {
  return (
    <>
      <FieldRow label="Plan name"><Input value={form.name} onChange={e=>setForm(p=>({...p,name:e.target.value}))} placeholder="e.g. Mediterranean Cut" /></FieldRow>
      <div style={{ display:'grid', gridTemplateColumns:'1fr 1fr', gap:12 }}>
        <FieldRow label="Goal">
          <Select value={form.goal} onChange={e=>setForm(p=>({...p,goal:e.target.value}))}>
            {goals.map(g=><option key={g}>{g}</option>)}
          </Select>
        </FieldRow>
        <FieldRow label="Daily kcal target"><Input type="number" value={form.kcal} onChange={e=>setForm(p=>({...p,kcal:e.target.value}))} placeholder="e.g. 2000" /></FieldRow>
      </div>
      <FieldRow label="Tag (e.g. Popular, New)"><Input value={form.tag} onChange={e=>setForm(p=>({...p,tag:e.target.value}))} placeholder="e.g. Best Seller" /></FieldRow>
      <FieldRow label="Color accent">
        <div style={{ display:'flex', gap:8 }}>
          {colors.map(c => (
            <div key={c} onClick={()=>setForm(p=>({...p,color:c}))} style={{ width:24, height:24, borderRadius:'50%', background:c, cursor:'pointer', border:form.color===c?`3px solid ${T.text}`:`3px solid transparent` }} />
          ))}
        </div>
      </FieldRow>
      <FieldRow label="Description"><Textarea value={form.desc} onChange={e=>setForm(p=>({...p,desc:e.target.value}))} placeholder="Describe this meal plan…" rows={3} /></FieldRow>
      <div style={{ display:'flex', gap:10, justifyContent:'flex-end', marginTop:8 }}>
        <Btn variant="ghost" onClick={onCancel}>Cancel</Btn>
        <Btn onClick={onSave}><Check size={13}/>Save</Btn>
      </div>
    </>
  );
}

function ContentForm({ form, setForm, onSave, onCancel }) {
  return (
    <>
      <FieldRow label="Title"><Input value={form.title} onChange={e=>setForm(p=>({...p,title:e.target.value}))} placeholder="Article title…" /></FieldRow>
      <div style={{ display:'grid', gridTemplateColumns:'1fr 1fr', gap:12 }}>
        <FieldRow label="Type">
          <Select value={form.type} onChange={e=>setForm(p=>({...p,type:e.target.value}))}>
            <option>Article</option><option>Guide</option><option>Recipe</option>
          </Select>
        </FieldRow>
        <FieldRow label="Status">
          <Select value={form.status} onChange={e=>setForm(p=>({...p,status:e.target.value}))}>
            <option>Draft</option><option>Review</option><option>Published</option>
          </Select>
        </FieldRow>
      </div>
      <FieldRow label="Author"><Input value={form.author} onChange={e=>setForm(p=>({...p,author:e.target.value}))} placeholder="Author name" /></FieldRow>
      <FieldRow label="Tags (comma-separated)"><Input value={form.tags} onChange={e=>setForm(p=>({...p,tags:e.target.value}))} placeholder="nutrition, protein, diet" /></FieldRow>
      <div style={{ display:'flex', gap:10, justifyContent:'flex-end', marginTop:8 }}>
        <Btn variant="ghost" onClick={onCancel}>Cancel</Btn>
        <Btn onClick={onSave}><Check size={13}/>Save</Btn>
      </div>
    </>
  );
}

// ─── KPI Card ─────────────────────────────────────────────────────────────────
function KpiCard({ Icon, label, value, change, up=true, color }) {
  return (
    <Card style={{ padding:'18px 20px' }}>
      <div style={{ display:'flex', alignItems:'center', justifyContent:'space-between', marginBottom:12 }}>
        <div style={{ width:34, height:34, borderRadius:9, background:`${color}18`, display:'flex', alignItems:'center', justifyContent:'center' }}>
          <Icon size={17} color={color} />
        </div>
        <span style={{ fontSize:11, color: up ? T.green : T.red, fontWeight:600 }}>
          {up ? '▲' : '▼'} {change}
        </span>
      </div>
      <div style={{ fontSize:24, fontWeight:800, color:T.text, letterSpacing:'-0.02em' }}>{value}</div>
      <div style={{ fontSize:12, color:T.muted, marginTop:3 }}>{label}</div>
    </Card>
  );
}

// ─── DASHBOARD PAGE ───────────────────────────────────────────────────────────
function DashboardPage() {
  const activities = [
    { Icon:Users,         text:'New user registered',       sub:'Amira Hassan · just now',           color:T.green },
    { Icon:Apple,         text:'Food submitted for review', sub:'Ful Medames · 2 min ago',           color:T.amber },
    { Icon:Shield,        text:'Security audit completed',  sub:'All systems clear · 15 min ago',    color:T.blue  },
    { Icon:DollarSign,    text:'New Pro subscription',      sub:'Karim Nour · 1 hr ago',             color:T.green },
    { Icon:AlertTriangle, text:'Failed payment retry',      sub:'User #4821 · 2 hr ago',             color:T.red   },
    { Icon:FileText,      text:'New article published',     sub:'Ramadan Nutrition Guide · 3 hr ago',color:T.muted },
  ];
  return (
    <div style={{ display:'flex', flexDirection:'column', gap:20 }}>
      <div style={{ display:'grid', gridTemplateColumns:'repeat(4,1fr)', gap:16 }}>
        <KpiCard Icon={Users}      label="Active users"       value="12,548"  change="8.2%"  color={T.green} />
        <KpiCard Icon={Activity}   label="Meals logged today" value="24,391"  change="12.5%" color={T.blue}  />
        <KpiCard Icon={DollarSign} label="Monthly revenue"    value="$38,240" change="5.1%"  color={T.amber} />
        <KpiCard Icon={Server}     label="System health"      value="99.8%"   change="0.1%"  color={T.green} />
      </div>
      <div style={{ display:'grid', gridTemplateColumns:'2fr 1fr', gap:16 }}>
        <Card style={{ padding:'20px 20px 12px' }}>
          <div style={{ display:'flex', alignItems:'center', justifyContent:'space-between', marginBottom:16 }}>
            <div>
              <div style={{ fontSize:14, fontWeight:600, color:T.text }}>User &amp; meal activity</div>
              <div style={{ fontSize:11, color:T.muted }}>Last 30 days</div>
            </div>
            <Badge>● Live</Badge>
          </div>
          <ResponsiveContainer width="100%" height={180}>
            <AreaChart data={areaData}>
              <defs>
                <linearGradient id="gu" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="5%"  stopColor={T.green} stopOpacity={0.28} />
                  <stop offset="95%" stopColor={T.green} stopOpacity={0} />
                </linearGradient>
                <linearGradient id="gm" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="5%"  stopColor={T.blue} stopOpacity={0.22} />
                  <stop offset="95%" stopColor={T.blue} stopOpacity={0} />
                </linearGradient>
              </defs>
              <XAxis dataKey="day" tick={{ fill:T.dim, fontSize:10 }} axisLine={false} tickLine={false} interval={4} />
              <YAxis tick={{ fill:T.dim, fontSize:10 }} axisLine={false} tickLine={false} width={44} />
              <Tooltip content={<ChartTip />} />
              <Area type="monotone" dataKey="users" name="Users" stroke={T.green} fill="url(#gu)" strokeWidth={2} dot={false} />
              <Area type="monotone" dataKey="meals" name="Meals" stroke={T.blue}  fill="url(#gm)" strokeWidth={2} dot={false} />
            </AreaChart>
          </ResponsiveContainer>
        </Card>
        <Card style={{ padding:20 }}>
          <div style={{ fontSize:14, fontWeight:600, color:T.text, marginBottom:4 }}>Plan distribution</div>
          <div style={{ fontSize:11, color:T.muted, marginBottom:12 }}>Active subscribers</div>
          <ResponsiveContainer width="100%" height={120}>
            <PieChart>
              <Pie data={pieData} cx="50%" cy="50%" innerRadius={36} outerRadius={55} paddingAngle={3} dataKey="v">
                {pieData.map((_, i) => <Cell key={i} fill={pieClrs[i]} />)}
              </Pie>
              <Tooltip formatter={v => `${v}%`} contentStyle={{ background:T.card, border:`1px solid ${T.border}`, borderRadius:8, fontSize:12 }} />
            </PieChart>
          </ResponsiveContainer>
          <div style={{ display:'flex', flexDirection:'column', gap:8, marginTop:12 }}>
            {pieData.map((p, i) => (
              <div key={i} style={{ display:'flex', alignItems:'center', justifyContent:'space-between' }}>
                <div style={{ display:'flex', alignItems:'center', gap:8 }}>
                  <div style={{ width:8, height:8, borderRadius:2, background:pieClrs[i] }} />
                  <span style={{ fontSize:12, color:T.muted }}>{p.name}</span>
                </div>
                <span style={{ fontSize:12, fontWeight:700, color:T.text }}>{p.v}%</span>
              </div>
            ))}
          </div>
        </Card>
      </div>
      <div style={{ display:'grid', gridTemplateColumns:'1fr 1fr', gap:16 }}>
        <Card style={{ padding:'20px 20px 12px' }}>
          <div style={{ fontSize:14, fontWeight:600, color:T.text, marginBottom:4 }}>Weekly meal logs</div>
          <div style={{ fontSize:11, color:T.muted, marginBottom:16 }}>Entries per day</div>
          <ResponsiveContainer width="100%" height={140}>
            <BarChart data={barData} barSize={22}>
              <XAxis dataKey="day" tick={{ fill:T.dim, fontSize:10 }} axisLine={false} tickLine={false} />
              <YAxis tick={{ fill:T.dim, fontSize:10 }} axisLine={false} tickLine={false} width={40} />
              <Tooltip contentStyle={{ background:T.card, border:`1px solid ${T.border}`, borderRadius:8, fontSize:12 }} cursor={{ fill:T.glow }} />
              <Bar dataKey="logs" name="Logs" fill={T.greenD} radius={[4,4,0,0]} />
            </BarChart>
          </ResponsiveContainer>
        </Card>
        <Card style={{ padding:20 }}>
          <div style={{ display:'flex', alignItems:'center', justifyContent:'space-between', marginBottom:14 }}>
            <div style={{ fontSize:14, fontWeight:600, color:T.text }}>Recent activity</div>
          </div>
          <div style={{ display:'flex', flexDirection:'column', gap:12 }}>
            {activities.map((a, i) => (
              <div key={i} style={{ display:'flex', alignItems:'center', gap:10 }}>
                <div style={{ width:30, height:30, borderRadius:8, background:`${a.color}18`, display:'flex', alignItems:'center', justifyContent:'center', flexShrink:0 }}>
                  <a.Icon size={14} color={a.color} />
                </div>
                <div style={{ flex:1, minWidth:0 }}>
                  <div style={{ fontSize:12, color:T.text, fontWeight:500, overflow:'hidden', textOverflow:'ellipsis', whiteSpace:'nowrap' }}>{a.text}</div>
                  <div style={{ fontSize:11, color:T.muted }}>{a.sub}</div>
                </div>
              </div>
            ))}
          </div>
        </Card>
      </div>
    </div>
  );
}

// ─── USERS PAGE ───────────────────────────────────────────────────────────────
function UsersPage() {
  const [users, setUsers] = useState(initialUsers);
  const [search, setSearch] = useState('');
  const [filter, setFilter] = useState('All');
  const [showAdd, setShowAdd] = useState(false);
  const [editUser, setEditUser] = useState(null);
  const [viewUser, setViewUser] = useState(null);
  const [deleteId, setDeleteId] = useState(null);
  const [form, setForm] = useState({ name:'', email:'', plan:'Free', status:'Active', country:'Egypt' });
  const planColor = { Pro:T.green, Free:T.muted, Family:T.blue };
  const filters = ['All','Pro','Free','Family','Active','Inactive'];

  const filtered = users.filter(u =>
    (filter === 'All' || u.plan === filter || u.status === filter) &&
    (u.name.toLowerCase().includes(search.toLowerCase()) || u.email.toLowerCase().includes(search.toLowerCase()))
  );

  function openAdd() { setForm({ name:'', email:'', plan:'Free', status:'Active', country:'Egypt' }); setShowAdd(true); }
  function openEdit(u) { setForm({ name:u.name, email:u.email, plan:u.plan, status:u.status, country:u.country }); setEditUser(u); }

  function saveAdd() {
    if (!form.name || !form.email) return;
    setUsers(prev => [...prev, { ...form, id:uid(), meals:0, joined:'May 2025', verified:false }]);
    setShowAdd(false);
  }

  function saveEdit() {
    setUsers(prev => prev.map(u => u.id === editUser.id ? { ...u, ...form } : u));
    setEditUser(null);
  }

  function doDelete() {
    setUsers(prev => prev.filter(u => u.id !== deleteId));
  }

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
                  onMouseEnter={e=>e.currentTarget.style.background=T.cardHov}
                  onMouseLeave={e=>e.currentTarget.style.background='transparent'}>
                  <td style={{ padding:'11px 16px' }}>
                    <div style={{ display:'flex', alignItems:'center', gap:10 }}>
                      <div style={{ width:32, height:32, borderRadius:'50%', background:T.glow, border:`1.5px solid ${T.green}30`, display:'flex', alignItems:'center', justifyContent:'center', fontSize:11, fontWeight:700, color:T.green, flexShrink:0 }}>
                        {u.name.split(' ').map(n=>n[0]).join('')}
                      </div>
                      <div>
                        <div style={{ color:T.text, fontWeight:500 }}>{u.name}</div>
                        {u.verified && <div style={{ fontSize:10, color:T.green }}>✓ Verified</div>}
                      </div>
                    </div>
                  </td>
                  <td style={{ padding:'11px 16px', color:T.muted }}>{u.email}</td>
                  <td style={{ padding:'11px 16px' }}><Badge color={planColor[u.plan]}>{u.plan}</Badge></td>
                  <td style={{ padding:'11px 16px' }}><Badge color={u.status==='Active'?T.green:T.red}>{u.status}</Badge></td>
                  <td style={{ padding:'11px 16px', color:T.text, fontWeight:600 }}>{u.meals.toLocaleString()}</td>
                  <td style={{ padding:'11px 16px', color:T.muted, whiteSpace:'nowrap' }}>{u.joined}</td>
                  <td style={{ padding:'11px 16px' }}>
                    <div style={{ display:'flex', gap:6 }}>
                      <button onClick={()=>setViewUser(u)} style={{ background:'none', border:`1px solid ${T.border}`, borderRadius:6, cursor:'pointer', color:T.muted, padding:'5px 7px', display:'flex', alignItems:'center' }}><Eye size={13}/></button>
                      <button onClick={()=>openEdit(u)} style={{ background:'none', border:`1px solid ${T.border}`, borderRadius:6, cursor:'pointer', color:T.muted, padding:'5px 7px', display:'flex', alignItems:'center' }}><Edit size={13}/></button>
                      <button onClick={()=>setDeleteId(u.id)} style={{ background:'none', border:`1px solid ${T.border}`, borderRadius:6, cursor:'pointer', color:T.red, padding:'5px 7px', display:'flex', alignItems:'center' }}><Trash2 size={13}/></button>
                    </div>
                  </td>
                </tr>
              ))}
              {filtered.length === 0 && (
                <tr><td colSpan={7} style={{ padding:32, textAlign:'center', color:T.muted, fontSize:13 }}>No users match your search.</td></tr>
              )}
            </tbody>
          </table>
        </div>
        <div style={{ padding:'12px 16px', borderTop:`1px solid ${T.border}`, display:'flex', alignItems:'center', justifyContent:'space-between', fontSize:12, color:T.muted }}>
          <span>Showing {filtered.length} of {users.length} users</span>
        </div>
      </Card>

      {/* Add Modal */}
      <Modal open={showAdd} onClose={()=>setShowAdd(false)} title="Add new user">
        <UserForm form={form} setForm={setForm} onSave={saveAdd} saving={true} onCancel={() => setShowAdd(false)} />
      </Modal>

      {/* Edit Modal */}
      <Modal open={!!editUser} onClose={()=>setEditUser(null)} title={`Edit — ${editUser?.name}`}>
        <UserForm form={form} setForm={setForm} onSave={saveEdit} saving={false} onCancel={() => setEditUser(null)} />
      </Modal>

      {/* View Modal */}
      <Modal open={!!viewUser} onClose={()=>setViewUser(null)} title="User profile" width={400}>
        {viewUser && (
          <div style={{ display:'flex', flexDirection:'column', gap:16 }}>
            <div style={{ display:'flex', alignItems:'center', gap:14 }}>
              <div style={{ width:52, height:52, borderRadius:'50%', background:T.glow, border:`2px solid ${T.green}40`, display:'flex', alignItems:'center', justifyContent:'center', fontSize:16, fontWeight:800, color:T.green }}>
                {viewUser.name.split(' ').map(n=>n[0]).join('')}
              </div>
              <div>
                <div style={{ fontSize:15, fontWeight:700, color:T.text }}>{viewUser.name}</div>
                <div style={{ fontSize:12, color:T.muted }}>{viewUser.email}</div>
              </div>
            </div>
            {[['Plan', <Badge color={({Pro:T.green,Free:T.muted,Family:T.blue})[viewUser.plan]}>{viewUser.plan}</Badge>],
              ['Status', <Badge color={viewUser.status==='Active'?T.green:T.red}>{viewUser.status}</Badge>],
              ['Country', viewUser.country], ['Meals logged', viewUser.meals.toLocaleString()], ['Joined', viewUser.joined],
              ['Verified', viewUser.verified ? '✓ Yes' : '✗ No']
            ].map(([k,v],i) => (
              <div key={i} style={{ display:'flex', justifyContent:'space-between', alignItems:'center', padding:'10px 0', borderBottom:`1px solid ${T.border}` }}>
                <span style={{ fontSize:12, color:T.muted }}>{k}</span>
                <span style={{ fontSize:12, color:T.text, fontWeight:600 }}>{v}</span>
              </div>
            ))}
            <div style={{ display:'flex', gap:10, justifyContent:'flex-end', marginTop:4 }}>
              <Btn variant="ghost" onClick={()=>{ setViewUser(null); openEdit(viewUser); }}><Edit size={13}/>Edit</Btn>
              <Btn variant="danger" onClick={()=>{ setViewUser(null); setDeleteId(viewUser.id); }}><Trash2 size={13}/>Delete</Btn>
            </div>
          </div>
        )}
      </Modal>

      {/* Delete Confirm */}
      <ConfirmModal open={!!deleteId} onClose={()=>setDeleteId(null)} onConfirm={doDelete}
        title="Delete user" message="This action is permanent and cannot be undone. Are you sure you want to delete this user and all their data?" danger />
    </div>
  );
}

// ─── FOOD DATABASE PAGE ───────────────────────────────────────────────────────
function FoodPage() {
  const [foods, setFoods] = useState(initialFoods);
  const [search, setSearch] = useState('');
  const [tab, setTab] = useState('All');
  const [showAdd, setShowAdd] = useState(false);
  const [editFood, setEditFood] = useState(null);
  const [deleteId, setDeleteId] = useState(null);
  const [form, setForm] = useState({ name:'', cal:'', protein:'', carbs:'', fat:'', cat:'Protein', status:'Pending' });
  const cats = ['All','Protein','Grain','Fat','Dairy','Vegetable','Legume'];

  const filtered = foods.filter(f =>
    (tab === 'All' || f.cat === tab) &&
    f.name.toLowerCase().includes(search.toLowerCase())
  );

  function openAdd() { setForm({ name:'', cal:'', protein:'', carbs:'', fat:'', cat:'Protein', status:'Pending' }); setShowAdd(true); }
  function openEdit(f) { setForm({ name:f.name, cal:String(f.cal), protein:String(f.protein), carbs:String(f.carbs), fat:String(f.fat), cat:f.cat, status:f.status }); setEditFood(f); }

  function saveAdd() {
    if (!form.name) return;
    setFoods(prev => [...prev, { id:uid(), ...form, cal:+form.cal, protein:+form.protein, carbs:+form.carbs, fat:+form.fat, logs:0 }]);
    setShowAdd(false);
  }
  function saveEdit() {
    setFoods(prev => prev.map(f => f.id === editFood.id ? { ...f, ...form, cal:+form.cal, protein:+form.protein, carbs:+form.carbs, fat:+form.fat } : f));
    setEditFood(null);
  }
  function approveFood(id) { setFoods(prev => prev.map(f => f.id === id ? { ...f, status:'Approved' } : f)); }
  function doDelete() { setFoods(prev => prev.filter(f => f.id !== deleteId)); }

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
                  <div style={{ fontSize:14, fontWeight:800, color:m.c }}>{m.v}</div>
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
        {filtered.length === 0 && (
          <div style={{ gridColumn:'1/-1', padding:40, textAlign:'center', color:T.muted, fontSize:13 }}>No food items found.</div>
        )}
      </div>

      <Modal open={showAdd} onClose={()=>setShowAdd(false)} title="Add food item" width={520}>
        <FoodForm form={form} setForm={setForm} onSave={saveAdd} onCancel={()=>setShowAdd(false)} cats={cats} />
      </Modal>
      <Modal open={!!editFood} onClose={()=>setEditFood(null)} title={`Edit — ${editFood?.name}`} width={520}>
        <FoodForm form={form} setForm={setForm} onSave={saveEdit} onCancel={()=>setEditFood(null)} cats={cats} />
      </Modal>
      <ConfirmModal open={!!deleteId} onClose={()=>setDeleteId(null)} onConfirm={doDelete}
        title="Delete food item" message="Remove this food item from the database permanently?" danger />
    </div>
  );
}

// ─── MEAL PLANS PAGE ──────────────────────────────────────────────────────────
function PlansPage() {
  const [plans, setPlans] = useState(initialPlans);
  const [showAdd, setShowAdd] = useState(false);
  const [editPlan, setEditPlan] = useState(null);
  const [deleteId, setDeleteId] = useState(null);
  const [form, setForm] = useState({ name:'', goal:'Weight Loss', kcal:'', tag:'', desc:'', color:T.green });
  const goals = ['Weight Loss','Muscle Gain','Fat Loss','Performance','Maintenance','Fasting'];
  const colors = [T.green, T.blue, T.amber, T.purple, T.greenL, T.red];

  function openAdd() { setForm({ name:'', goal:'Weight Loss', kcal:'', tag:'', desc:'', color:T.green }); setShowAdd(true); }
  function openEdit(p) { setForm({ name:p.name, goal:p.goal, kcal:String(p.kcal), tag:p.tag, desc:p.desc, color:p.color }); setEditPlan(p); }

  function saveAdd() {
    if (!form.name) return;
    setPlans(prev => [...prev, { id:uid(), ...form, kcal:+form.kcal, users:0, active:true }]);
    setShowAdd(false);
  }
  function saveEdit() {
    setPlans(prev => prev.map(p => p.id === editPlan.id ? { ...p, ...form, kcal:+form.kcal } : p));
    setEditPlan(null);
  }
  function toggleActive(id) { setPlans(prev => prev.map(p => p.id === id ? { ...p, active:!p.active } : p)); }
  function doDelete() { setPlans(prev => prev.filter(p => p.id !== deleteId)); }

  return (
    <div>
      <div style={{ display:'flex', alignItems:'center', justifyContent:'space-between', marginBottom:20 }}>
        <div>
          <div style={{ fontSize:15, fontWeight:700, color:T.text }}>Meal plan library</div>
          <div style={{ fontSize:12, color:T.muted }}>{plans.length} plans · {plans.reduce((a,p)=>a+p.users,0).toLocaleString()} users assigned</div>
        </div>
        <Btn onClick={openAdd}><Plus size={14}/> New plan</Btn>
      </div>
      <div style={{ display:'grid', gridTemplateColumns:'repeat(3,1fr)', gap:14 }}>
        {plans.map((p) => (
          <Card key={p.id} style={{ padding:20, display:'flex', flexDirection:'column', opacity:p.active?1:0.55 }}>
            <div style={{ display:'flex', alignItems:'center', justifyContent:'space-between', marginBottom:12 }}>
              <Badge color={p.color}>{p.tag}</Badge>
              <span style={{ fontSize:11, color:T.muted }}>{p.users.toLocaleString()} users</span>
            </div>
            <div style={{ fontSize:16, fontWeight:800, color:T.text, marginBottom:2 }}>{p.name}</div>
            <div style={{ fontSize:11, color:p.color, fontWeight:600, marginBottom:10 }}>{p.goal}</div>
            <div style={{ fontSize:12, color:T.muted, lineHeight:1.65, flex:1, marginBottom:14 }}>{p.desc}</div>
            <div style={{ display:'flex', alignItems:'center', justifyContent:'space-between', padding:'10px 13px', background:T.surf, borderRadius:9, marginBottom:14 }}>
              <span style={{ fontSize:11, color:T.muted }}>Daily target</span>
              <span style={{ fontSize:15, fontWeight:800, color:p.color }}>{p.kcal.toLocaleString()} kcal</span>
            </div>
            <div style={{ display:'flex', gap:8 }}>
              <Btn onClick={()=>openEdit(p)} style={{ flex:1, justifyContent:'center' }}><Edit size={13}/>Edit</Btn>
              <Btn variant="ghost" onClick={()=>toggleActive(p.id)} style={{ justifyContent:'center' }}>{p.active?'Pause':'Resume'}</Btn>
              <Btn variant="danger" onClick={()=>setDeleteId(p.id)}><Trash2 size={13}/></Btn>
            </div>
          </Card>
        ))}
      </div>

      <Modal open={showAdd} onClose={()=>setShowAdd(false)} title="New meal plan" width={500}>
        <PlanForm form={form} setForm={setForm} onSave={saveAdd} onCancel={()=>setShowAdd(false)} goals={goals} colors={colors} />
      </Modal>
      <Modal open={!!editPlan} onClose={()=>setEditPlan(null)} title={`Edit — ${editPlan?.name}`} width={500}>
        <PlanForm form={form} setForm={setForm} onSave={saveEdit} onCancel={()=>setEditPlan(null)} goals={goals} colors={colors} />
      </Modal>
      <ConfirmModal open={!!deleteId} onClose={()=>setDeleteId(null)} onConfirm={doDelete}
        title="Delete plan" message="This will remove the meal plan and unassign all users from it." danger />
    </div>
  );
}

// ─── ANALYTICS PAGE ───────────────────────────────────────────────────────────
function AnalyticsPage() {
  const [range, setRange] = useState('30d');
  const revenueData = Array.from({ length: 12 }, (_, i) => ({
    month: ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][i],
    revenue: Math.floor(24000 + i * 1200 + (i * 37 % 4000)),
    subs: Math.floor(800 + i * 60 + (i * 23 % 200)),
  }));

  return (
    <div style={{ display:'flex', flexDirection:'column', gap:20 }}>
      <div style={{ display:'flex', alignItems:'center', justifyContent:'space-between' }}>
        <div style={{ fontSize:15, fontWeight:700, color:T.text }}>Analytics overview</div>
        <div style={{ display:'flex', gap:6 }}>
          {['7d','30d','90d','1y'].map(r => (
            <button key={r} onClick={()=>setRange(r)} style={{ padding:'5px 12px', borderRadius:7, fontSize:11, cursor:'pointer', fontWeight:600, background:range===r?T.green:T.card, color:range===r?'#000':T.muted, border:`1px solid ${range===r?T.green:T.border}` }}>{r}</button>
          ))}
        </div>
      </div>

      <div style={{ display:'grid', gridTemplateColumns:'repeat(4,1fr)', gap:14 }}>
        {[
          { label:'Daily active users', val:'12,548', d:'+8.2%',  color:T.green, up:true  },
          { label:'Avg. session length', val:'7m 23s', d:'+1m 02s',color:T.blue,  up:true  },
          { label:'Goal achievement',    val:'64.2%',  d:'+3.1%',  color:T.amber, up:true  },
          { label:'Monthly churn',       val:'2.3%',   d:'−0.4%',  color:T.green, up:false },
        ].map((m,i)=>(
          <Card key={i} style={{ padding:'16px 18px' }}>
            <div style={{ fontSize:11, color:T.muted, marginBottom:6 }}>{m.label}</div>
            <div style={{ fontSize:22, fontWeight:800, color:T.text, letterSpacing:'-0.02em' }}>{m.val}</div>
            <div style={{ fontSize:11, color:m.color, marginTop:3, fontWeight:600, display:'flex', alignItems:'center', gap:4 }}>
              {m.up ? <TrendingUp size={11}/> : <TrendingDown size={11}/>} {m.d} vs last month
            </div>
          </Card>
        ))}
      </div>

      <Card style={{ padding:'20px 20px 12px' }}>
        <div style={{ fontSize:14, fontWeight:600, color:T.text, marginBottom:4 }}>User growth — 30 days</div>
        <div style={{ fontSize:11, color:T.muted, marginBottom:16 }}>Active users (green) and meal logs (amber)</div>
        <ResponsiveContainer width="100%" height={200}>
          <AreaChart data={areaData}>
            <defs>
              <linearGradient id="ag" x1="0" y1="0" x2="0" y2="1">
                <stop offset="5%" stopColor={T.green} stopOpacity={0.3}/><stop offset="95%" stopColor={T.green} stopOpacity={0}/>
              </linearGradient>
              <linearGradient id="aa" x1="0" y1="0" x2="0" y2="1">
                <stop offset="5%" stopColor={T.amber} stopOpacity={0.25}/><stop offset="95%" stopColor={T.amber} stopOpacity={0}/>
              </linearGradient>
            </defs>
            <XAxis dataKey="day" tick={{ fill:T.dim, fontSize:10 }} axisLine={false} tickLine={false} interval={4} />
            <YAxis tick={{ fill:T.dim, fontSize:10 }} axisLine={false} tickLine={false} width={44} />
            <Tooltip content={<ChartTip />} />
            <Area type="monotone" dataKey="users" name="Users" stroke={T.green} fill="url(#ag)" strokeWidth={2} dot={false}/>
            <Area type="monotone" dataKey="meals" name="Meals" stroke={T.amber} fill="url(#aa)" strokeWidth={2} dot={false}/>
          </AreaChart>
        </ResponsiveContainer>
      </Card>

      <div style={{ display:'grid', gridTemplateColumns:'1fr 1fr', gap:16 }}>
        <Card style={{ padding:'20px 20px 12px' }}>
          <div style={{ fontSize:14, fontWeight:600, color:T.text, marginBottom:4 }}>Monthly revenue</div>
          <div style={{ fontSize:11, color:T.muted, marginBottom:16 }}>USD · All plans</div>
          <ResponsiveContainer width="100%" height={160}>
            <LineChart data={revenueData}>
              <XAxis dataKey="month" tick={{ fill:T.dim, fontSize:10 }} axisLine={false} tickLine={false} />
              <YAxis tick={{ fill:T.dim, fontSize:10 }} axisLine={false} tickLine={false} width={50} tickFormatter={v=>`$${(v/1000).toFixed(0)}k`} />
              <Tooltip contentStyle={{ background:T.card, border:`1px solid ${T.border}`, borderRadius:8, fontSize:12 }} />
              <Line type="monotone" dataKey="revenue" name="Revenue" stroke={T.amber} strokeWidth={2} dot={false} />
            </LineChart>
          </ResponsiveContainer>
        </Card>

        <Card style={{ padding:20 }}>
          <div style={{ fontSize:14, fontWeight:600, color:T.text, marginBottom:16 }}>Top nutritional goals</div>
          {[
            { label:'Weight loss',  pct:42, color:T.green  },
            { label:'Muscle gain',  pct:28, color:T.blue   },
            { label:'Maintenance',  pct:18, color:T.amber  },
            { label:'Performance',  pct:12, color:T.purple },
          ].map((g,i)=>(
            <div key={i} style={{ marginBottom:14 }}>
              <div style={{ display:'flex', justifyContent:'space-between', marginBottom:5 }}>
                <span style={{ fontSize:12, color:T.muted }}>{g.label}</span>
                <span style={{ fontSize:12, fontWeight:700, color:T.text }}>{g.pct}%</span>
              </div>
              <div style={{ height:5, background:T.dim, borderRadius:4, overflow:'hidden' }}>
                <div style={{ height:'100%', width:`${g.pct}%`, background:g.color, borderRadius:4 }} />
              </div>
            </div>
          ))}
        </Card>
      </div>

      <div style={{ display:'grid', gridTemplateColumns:'1fr 1fr', gap:16 }}>
        <Card style={{ padding:'20px 20px 12px' }}>
          <div style={{ fontSize:14, fontWeight:600, color:T.text, marginBottom:16 }}>Meal logs by day of week</div>
          <ResponsiveContainer width="100%" height={150}>
            <BarChart data={barData} barSize={24}>
              <XAxis dataKey="day" tick={{ fill:T.dim, fontSize:10 }} axisLine={false} tickLine={false} />
              <YAxis tick={{ fill:T.dim, fontSize:10 }} axisLine={false} tickLine={false} width={40} />
              <Tooltip contentStyle={{ background:T.card, border:`1px solid ${T.border}`, borderRadius:8, fontSize:12 }} cursor={{ fill:T.glow }} />
              <Bar dataKey="logs" name="Logs" fill={T.greenD} radius={[4,4,0,0]} />
            </BarChart>
          </ResponsiveContainer>
        </Card>
        <Card style={{ padding:20 }}>
          <div style={{ fontSize:14, fontWeight:600, color:T.text, marginBottom:16 }}>Top countries</div>
          {[
            { country:'Egypt', users:7820, pct:62 },
            { country:'UAE', users:2140, pct:17 },
            { country:'Saudi Arabia', users:1250, pct:10 },
            { country:'Jordan', users:880, pct:7 },
            { country:'Lebanon', users:458, pct:4 },
          ].map((c,i) => (
            <div key={i} style={{ display:'flex', alignItems:'center', gap:12, marginBottom:12 }}>
              <div style={{ width:24, height:24, borderRadius:6, background:`${T.green}18`, display:'flex', alignItems:'center', justifyContent:'center', flexShrink:0 }}>
                <Globe size={12} color={T.green} />
              </div>
              <div style={{ flex:1 }}>
                <div style={{ display:'flex', justifyContent:'space-between', marginBottom:4 }}>
                  <span style={{ fontSize:12, color:T.text }}>{c.country}</span>
                  <span style={{ fontSize:11, color:T.muted }}>{c.users.toLocaleString()}</span>
                </div>
                <div style={{ height:3, background:T.dim, borderRadius:4 }}>
                  <div style={{ height:'100%', width:`${c.pct}%`, background:T.green, borderRadius:4 }} />
                </div>
              </div>
            </div>
          ))}
        </Card>
      </div>
    </div>
  );
}

// ─── NOTIFICATIONS PAGE ───────────────────────────────────────────────────────
function NotificationsPage() {
  const [notifs, setNotifs] = useState(initialNotifications);
  const [filter, setFilter] = useState('All');
  const typeIcon = { user:Users, food:Apple, security:Shield, billing:DollarSign, alert:AlertTriangle, content:FileText };
  const typeColor = { user:T.green, food:T.amber, security:T.blue, billing:T.green, alert:T.red, content:T.muted };

  const unread = notifs.filter(n=>!n.read).length;

  const filtered = notifs.filter(n =>
    filter === 'All' || (filter === 'Unread' && !n.read) ||
    (filter === 'High priority' && n.priority === 'high') ||
    filter.toLowerCase() === n.type
  );

  function markRead(id) { setNotifs(prev => prev.map(n => n.id===id ? {...n, read:true} : n)); }
  function markAllRead() { setNotifs(prev => prev.map(n => ({...n, read:true}))); }
  function dismiss(id) { setNotifs(prev => prev.filter(n => n.id !== id)); }

  const filters = ['All','Unread','High priority','user','security','billing','content'];

  return (
    <div style={{ display:'flex', flexDirection:'column', gap:16 }}>
      <div style={{ display:'flex', alignItems:'center', justifyContent:'space-between' }}>
        <div>
          <div style={{ fontSize:15, fontWeight:700, color:T.text }}>Notifications</div>
          <div style={{ fontSize:12, color:T.muted }}>{unread} unread</div>
        </div>
        <Btn variant="ghost" onClick={markAllRead}><CheckCircle size={14}/>Mark all read</Btn>
      </div>

      <div style={{ display:'flex', gap:6, flexWrap:'wrap' }}>
        {filters.map(f => (
          <button key={f} onClick={()=>setFilter(f)} style={{ padding:'5px 12px', borderRadius:20, fontSize:11, cursor:'pointer', fontWeight:600, background:filter===f?T.green:T.card, color:filter===f?'#000':T.muted, border:`1px solid ${filter===f?T.green:T.border}`, textTransform:'capitalize' }}>{f}</button>
        ))}
      </div>

      <Card>
        {filtered.length === 0 && (
          <div style={{ padding:40, textAlign:'center', color:T.muted, fontSize:13 }}>No notifications here.</div>
        )}
        {filtered.map((n, i) => {
          const Icon = typeIcon[n.type] || Bell;
          const color = typeColor[n.type] || T.muted;
          return (
            <div key={n.id} style={{ display:'flex', alignItems:'flex-start', gap:14, padding:'14px 18px', borderBottom:i<filtered.length-1?`1px solid ${T.border}`:'none', background:n.read?'transparent':`${T.green}06`, transition:'background .15s' }}
              onMouseEnter={e=>e.currentTarget.style.background=T.cardHov}
              onMouseLeave={e=>e.currentTarget.style.background=n.read?'transparent':`${T.green}06`}>
              <div style={{ width:34, height:34, borderRadius:9, background:`${color}18`, display:'flex', alignItems:'center', justifyContent:'center', flexShrink:0, marginTop:2 }}>
                <Icon size={15} color={color} />
              </div>
              <div style={{ flex:1, minWidth:0 }}>
                <div style={{ display:'flex', alignItems:'center', gap:8, marginBottom:3 }}>
                  <span style={{ fontSize:13, fontWeight:n.read?500:700, color:T.text }}>{n.title}</span>
                  {n.priority === 'high' && <Badge color={T.red}>High</Badge>}
                  {!n.read && <div style={{ width:6, height:6, borderRadius:'50%', background:T.green, flexShrink:0 }} />}
                </div>
                <div style={{ fontSize:12, color:T.muted, marginBottom:4 }}>{n.body}</div>
                <div style={{ fontSize:11, color:T.dim }}>{n.time}</div>
              </div>
              <div style={{ display:'flex', gap:6, flexShrink:0 }}>
                {!n.read && <button onClick={()=>markRead(n.id)} style={{ background:'none', border:`1px solid ${T.border}`, borderRadius:6, cursor:'pointer', color:T.green, padding:'4px 8px', fontSize:11 }}>Read</button>}
                <button onClick={()=>dismiss(n.id)} style={{ background:'none', border:`1px solid ${T.border}`, borderRadius:6, cursor:'pointer', color:T.muted, padding:'4px', display:'flex', alignItems:'center' }}><X size={12}/></button>
              </div>
            </div>
          );
        })}
      </Card>
    </div>
  );
}

// ─── CONTENT PAGE ─────────────────────────────────────────────────────────────
function ContentPage() {
  const [content, setContent] = useState(initialContent);
  const [search, setSearch] = useState('');
  const [filter, setFilter] = useState('All');
  const [showAdd, setShowAdd] = useState(false);
  const [editItem, setEditItem] = useState(null);
  const [deleteId, setDeleteId] = useState(null);
  const [form, setForm] = useState({ title:'', type:'Article', status:'Draft', author:'Admin', tags:'' });
  const statusColor = { Published:T.green, Draft:T.muted, Review:T.amber };
  const typeColor2 = { Article:T.blue, Guide:T.purple, Recipe:T.amber };
  const filters = ['All','Published','Draft','Review'];

  const filtered = content.filter(c =>
    (filter === 'All' || c.status === filter) &&
    c.title.toLowerCase().includes(search.toLowerCase())
  );

  function openAdd() { setForm({ title:'', type:'Article', status:'Draft', author:'Admin', tags:'' }); setShowAdd(true); }
  function openEdit(c) { setForm({ title:c.title, type:c.type, status:c.status, author:c.author, tags:c.tags.join(', ') }); setEditItem(c); }

  function saveAdd() {
    if (!form.title) return;
    setContent(prev => [...prev, { id:uid(), ...form, tags:form.tags.split(',').map(t=>t.trim()).filter(Boolean), views:0, date:'May 2025' }]);
    setShowAdd(false);
  }
  function saveEdit() {
    setContent(prev => prev.map(c => c.id===editItem.id ? { ...c, ...form, tags:form.tags.split(',').map(t=>t.trim()).filter(Boolean) } : c));
    setEditItem(null);
  }
  function publishItem(id) { setContent(prev => prev.map(c => c.id===id ? {...c, status:'Published'} : c)); }
  function doDelete() { setContent(prev => prev.filter(c => c.id !== deleteId)); }

  return (
    <div style={{ display:'flex', flexDirection:'column', gap:16 }}>
      <div style={{ display:'flex', alignItems:'center', gap:10, flexWrap:'wrap' }}>
        <div style={{ position:'relative', flex:1, minWidth:180 }}>
          <Search size={14} color={T.muted} style={{ position:'absolute', left:11, top:'50%', transform:'translateY(-50%)', pointerEvents:'none' }} />
          <input value={search} onChange={e=>setSearch(e.target.value)} placeholder="Search content…"
            style={{ width:'100%', background:T.card, border:`1px solid ${T.border}`, borderRadius:8, padding:'8px 12px 8px 34px', color:T.text, fontSize:13, outline:'none', boxSizing:'border-box' }} />
        </div>
        <div style={{ display:'flex', gap:6 }}>
          {filters.map(f=>(
            <button key={f} onClick={()=>setFilter(f)} style={{ padding:'7px 13px', borderRadius:7, fontSize:12, cursor:'pointer', fontWeight:500, background:filter===f?T.green:T.card, color:filter===f?'#000':T.muted, border:`1px solid ${filter===f?T.green:T.border}` }}>{f}</button>
          ))}
        </div>
        <Btn onClick={openAdd}><Plus size={14}/>New article</Btn>
      </div>

      <Card>
        <table style={{ width:'100%', borderCollapse:'collapse', fontSize:13 }}>
          <thead>
            <tr style={{ borderBottom:`1px solid ${T.border}` }}>
              {['Title','Type','Status','Author','Views','Date','Actions'].map(h => (
                <th key={h} style={{ padding:'12px 16px', textAlign:'left', fontSize:10, fontWeight:700, color:T.muted, letterSpacing:'0.08em', textTransform:'uppercase', whiteSpace:'nowrap' }}>{h}</th>
              ))}
            </tr>
          </thead>
          <tbody>
            {filtered.map((c, i) => (
              <tr key={c.id} style={{ borderBottom:i<filtered.length-1?`1px solid ${T.border}`:'none', transition:'background .15s' }}
                onMouseEnter={e=>e.currentTarget.style.background=T.cardHov}
                onMouseLeave={e=>e.currentTarget.style.background='transparent'}>
                <td style={{ padding:'11px 16px' }}>
                  <div style={{ color:T.text, fontWeight:500, maxWidth:220, overflow:'hidden', textOverflow:'ellipsis', whiteSpace:'nowrap' }}>{c.title}</div>
                  <div style={{ display:'flex', gap:4, marginTop:4, flexWrap:'wrap' }}>
                    {c.tags.map(t=><span key={t} style={{ fontSize:10, color:T.muted, background:T.dim, padding:'1px 6px', borderRadius:10 }}>{t}</span>)}
                  </div>
                </td>
                <td style={{ padding:'11px 16px' }}><Badge color={typeColor2[c.type]||T.muted}>{c.type}</Badge></td>
                <td style={{ padding:'11px 16px' }}><Badge color={statusColor[c.status]||T.muted}>{c.status}</Badge></td>
                <td style={{ padding:'11px 16px', color:T.muted, fontSize:12 }}>{c.author}</td>
                <td style={{ padding:'11px 16px', color:T.text, fontWeight:600 }}>{c.views.toLocaleString()}</td>
                <td style={{ padding:'11px 16px', color:T.muted, whiteSpace:'nowrap', fontSize:12 }}>{c.date}</td>
                <td style={{ padding:'11px 16px' }}>
                  <div style={{ display:'flex', gap:6 }}>
                    {c.status !== 'Published' && <button onClick={()=>publishItem(c.id)} style={{ background:'none', border:`1px solid ${T.green}40`, borderRadius:6, cursor:'pointer', color:T.green, padding:'5px 8px', fontSize:11 }}>Publish</button>}
                    <button onClick={()=>openEdit(c)} style={{ background:'none', border:`1px solid ${T.border}`, borderRadius:6, cursor:'pointer', color:T.muted, padding:'5px 7px', display:'flex', alignItems:'center' }}><Edit size={13}/></button>
                    <button onClick={()=>setDeleteId(c.id)} style={{ background:'none', border:`1px solid ${T.border}`, borderRadius:6, cursor:'pointer', color:T.red, padding:'5px 7px', display:'flex', alignItems:'center' }}><Trash2 size={13}/></button>
                  </div>
                </td>
              </tr>
            ))}
            {filtered.length===0 && (
              <tr><td colSpan={7} style={{ padding:32, textAlign:'center', color:T.muted, fontSize:13 }}>No content found.</td></tr>
            )}
          </tbody>
        </table>
      </Card>

      <Modal open={showAdd} onClose={()=>setShowAdd(false)} title="New content" width={500}>
        <ContentForm form={form} setForm={setForm} onSave={saveAdd} onCancel={()=>setShowAdd(false)} />
      </Modal>
      <Modal open={!!editItem} onClose={()=>setEditItem(null)} title={`Edit — ${editItem?.title}`} width={500}>
        <ContentForm form={form} setForm={setForm} onSave={saveEdit} onCancel={()=>setEditItem(null)} />
      </Modal>
      <ConfirmModal open={!!deleteId} onClose={()=>setDeleteId(null)} onConfirm={doDelete}
        title="Delete content" message="This will permanently delete this article or guide." danger />
    </div>
  );
}

// ─── SECURITY PAGE ────────────────────────────────────────────────────────────
function SecurityPage() {
  const [twoFA, setTwoFA] = useState(true);
  const [ipWhitelist, setIpWhitelist] = useState(false);
  const [sessionTimeout, setSessionTimeout] = useState(true);
  const [auditLog, setAuditLog] = useState(true);
  const [showApiModal, setShowApiModal] = useState(false);
  const [apiKey, setApiKey] = useState('bsm_live_••••••••••••••••••••••••••••••');
  const [revealed, setRevealed] = useState(false);
  const [newIp, setNewIp] = useState('');
  const [whitelistedIps, setWhitelistedIps] = useState(['192.168.1.0/24', '10.0.0.1']);

  const logs = [
    { action:'Admin login',         user:'admin@bitesmart.app',   ip:'197.32.45.1',   time:'Today 14:32',    status:'success' },
    { action:'User deleted',         user:'admin@bitesmart.app',   ip:'197.32.45.1',   time:'Today 14:10',    status:'success' },
    { action:'API key rotated',      user:'admin@bitesmart.app',   ip:'197.32.45.1',   time:'Today 11:05',    status:'success' },
    { action:'Failed login attempt', user:'unknown@attacker.com',  ip:'45.33.32.156',  time:'Today 09:18',    status:'fail'    },
    { action:'Settings changed',     user:'admin@bitesmart.app',   ip:'197.32.45.1',   time:'Yesterday 18:00',status:'success' },
    { action:'New admin invited',    user:'admin@bitesmart.app',   ip:'197.32.45.1',   time:'May 14, 09:22',  status:'success' },
  ];

  function rotateKey() {
    setApiKey('bsm_live_' + Math.random().toString(36).substr(2, 32));
    setRevealed(true);
    setShowApiModal(false);
  }

  function addIp() {
    if (newIp && !whitelistedIps.includes(newIp)) {
      setWhitelistedIps(p => [...p, newIp]);
      setNewIp('');
    }
  }

  return (
    <div style={{ display:'flex', flexDirection:'column', gap:16, maxWidth:720 }}>
      {/* Status */}
      <Card style={{ padding:20 }}>
        <div style={{ display:'flex', alignItems:'center', gap:14 }}>
          <div style={{ width:44, height:44, borderRadius:12, background:`${T.green}18`, display:'flex', alignItems:'center', justifyContent:'center' }}>
            <Shield size={22} color={T.green} />
          </div>
          <div>
            <div style={{ fontSize:14, fontWeight:700, color:T.text }}>Security status: All clear</div>
            <div style={{ fontSize:12, color:T.muted }}>Last audit: Today, 14:30 · No vulnerabilities found</div>
          </div>
          <Btn variant="ghost" style={{ marginLeft:'auto' }} onClick={()=>{}}><RefreshCw size={13}/>Run audit</Btn>
        </div>
      </Card>

      {/* Toggles */}
      <Card style={{ padding:24 }}>
        <div style={{ fontSize:13, fontWeight:700, color:T.text, marginBottom:16, paddingBottom:12, borderBottom:`1px solid ${T.border}` }}>Security settings</div>
        <div style={{ display:'flex', flexDirection:'column', gap:18 }}>
          {[
            { label:'Two-factor authentication', sub:'Require 2FA for all admin accounts', val:twoFA, set:setTwoFA },
            { label:'IP whitelist', sub:'Restrict admin access to approved IP addresses', val:ipWhitelist, set:setIpWhitelist },
            { label:'Session timeout (30 min)', sub:'Auto-logout after 30 minutes of inactivity', val:sessionTimeout, set:setSessionTimeout },
            { label:'Audit logging', sub:'Log all admin actions for compliance review', val:auditLog, set:setAuditLog },
          ].map((s,i) => (
            <div key={i} style={{ display:'flex', alignItems:'center', justifyContent:'space-between' }}>
              <div>
                <div style={{ fontSize:13, color:T.text, fontWeight:500 }}>{s.label}</div>
                <div style={{ fontSize:11, color:T.muted }}>{s.sub}</div>
              </div>
              <Toggle val={s.val} onToggle={()=>s.set(v=>!v)} />
            </div>
          ))}
        </div>
      </Card>

      {/* IP whitelist manager */}
      {ipWhitelist && (
        <Card style={{ padding:24 }}>
          <div style={{ fontSize:13, fontWeight:700, color:T.text, marginBottom:16, paddingBottom:12, borderBottom:`1px solid ${T.border}` }}>Whitelisted IP addresses</div>
          {whitelistedIps.map((ip, i) => (
            <div key={i} style={{ display:'flex', alignItems:'center', justifyContent:'space-between', padding:'9px 12px', background:T.surf, borderRadius:8, marginBottom:8 }}>
              <span style={{ fontSize:13, color:T.text, fontFamily:'monospace' }}>{ip}</span>
              <button onClick={()=>setWhitelistedIps(p=>p.filter((_,j)=>j!==i))} style={{ background:'none', border:'none', cursor:'pointer', color:T.red, display:'flex', alignItems:'center' }}><X size={14}/></button>
            </div>
          ))}
          <div style={{ display:'flex', gap:8, marginTop:8 }}>
            <Input value={newIp} onChange={e=>setNewIp(e.target.value)} placeholder="Add IP (e.g. 192.168.1.1)" style={{ flex:1 }} />
            <Btn onClick={addIp}><Plus size={13}/>Add</Btn>
          </div>
        </Card>
      )}

      {/* API Key */}
      <Card style={{ padding:24 }}>
        <div style={{ fontSize:13, fontWeight:700, color:T.text, marginBottom:16, paddingBottom:12, borderBottom:`1px solid ${T.border}` }}>API key management</div>
        <div style={{ display:'flex', alignItems:'center', gap:10 }}>
          <input readOnly value={revealed ? apiKey : 'bsm_live_••••••••••••••••••••••••••••••'}
            style={{ flex:1, background:T.surf, border:`1px solid ${T.border}`, borderRadius:8, padding:'9px 13px', color:T.text, fontSize:12, fontFamily:'monospace', outline:'none' }} />
          <Btn variant="ghost" onClick={()=>setRevealed(v=>!v)}><Eye size={13}/>{revealed?'Hide':'Show'}</Btn>
          <Btn variant="danger" onClick={()=>setShowApiModal(true)}><RefreshCw size={13}/>Rotate</Btn>
        </div>
      </Card>

      {/* Audit log */}
      <Card style={{ padding:24 }}>
        <div style={{ display:'flex', alignItems:'center', justifyContent:'space-between', marginBottom:16, paddingBottom:12, borderBottom:`1px solid ${T.border}` }}>
          <div style={{ fontSize:13, fontWeight:700, color:T.text }}>Audit log</div>
          <Btn variant="ghost" size="sm"><Download size={12}/>Export CSV</Btn>
        </div>
        {logs.map((l,i) => (
          <div key={i} style={{ display:'flex', alignItems:'center', gap:12, padding:'10px 0', borderBottom:i<logs.length-1?`1px solid ${T.border}`:'none' }}>
            <div style={{ width:28, height:28, borderRadius:7, background:l.status==='success'?`${T.green}18`:`${T.red}18`, display:'flex', alignItems:'center', justifyContent:'center', flexShrink:0 }}>
              {l.status==='success' ? <CheckCircle size={13} color={T.green}/> : <XCircle size={13} color={T.red}/>}
            </div>
            <div style={{ flex:1 }}>
              <div style={{ fontSize:12, color:T.text, fontWeight:500 }}>{l.action}</div>
              <div style={{ fontSize:11, color:T.muted }}>{l.user} · {l.ip}</div>
            </div>
            <span style={{ fontSize:11, color:T.dim, whiteSpace:'nowrap' }}>{l.time}</span>
          </div>
        ))}
      </Card>

      <ConfirmModal open={showApiModal} onClose={()=>setShowApiModal(false)} onConfirm={rotateKey}
        title="Rotate API key"
        message="This will immediately invalidate your current key. Any services using it will stop working until updated with the new key." danger />
    </div>
  );
}

// ─── SETTINGS PAGE ────────────────────────────────────────────────────────────
function SettingsPage() {
  const [notifs, setNotifs] = useState({ email:true, push:true, sms:false, digest:true });
  const [darkMode, setDarkMode] = useState(true);
  const [maint, setMaint] = useState(false);
  const [saved, setSaved] = useState(false);
  const [integrations, setIntegrations] = useState([
    { name:'Stripe',    desc:'Payment processing', connected:true   },
    { name:'AWS S3',    desc:'File storage',       connected:true   },
    { name:'SendGrid',  desc:'Email delivery',     connected:true   },
    { name:'Twilio',    desc:'SMS notifications',  connected:false  },
    { name:'Firebase',  desc:'Push notifications', connected:true   },
    { name:'Sentry',    desc:'Error tracking',     connected:false  },
  ]);
  const [appName, setAppName] = useState('Bite Smart');
  const [supportEmail, setSupportEmail] = useState('support@bitesmart.app');

  function toggleIntegration(name) { setIntegrations(prev => prev.map(i => i.name===name ? {...i,connected:!i.connected} : i)); }

  function handleSave() {
    setSaved(true);
    setTimeout(() => setSaved(false), 2500);
  }

  const inputStyle = { width:'100%', background:T.surf, border:`1px solid ${T.border}`, borderRadius:8, padding:'9px 13px', color:T.text, fontSize:13, outline:'none', boxSizing:'border-box' };
  const sectionHead = { fontSize:13, fontWeight:700, color:T.text, marginBottom:16, paddingBottom:12, borderBottom:`1px solid ${T.border}` };

  return (
    <div style={{ display:'flex', flexDirection:'column', gap:16, maxWidth:680 }}>
      {saved && (
        <div style={{ background:`${T.green}18`, border:`1px solid ${T.green}40`, borderRadius:10, padding:'10px 16px', display:'flex', alignItems:'center', gap:8, color:T.green, fontSize:13 }}>
          <Check size={14}/>Settings saved successfully.
        </div>
      )}

      <Card style={{ padding:24 }}>
        <div style={sectionHead}>General settings</div>
        <div style={{ display:'flex', flexDirection:'column', gap:16 }}>
          {[
            { label:'App name', val:appName, set:setAppName },
            { label:'Support email', val:supportEmail, set:setSupportEmail },
          ].map((f,i)=>(
            <div key={i}>
              <div style={{ fontSize:10, color:T.muted, marginBottom:6, fontWeight:700, textTransform:'uppercase', letterSpacing:'0.08em' }}>{f.label}</div>
              <input value={f.val} onChange={e=>f.set(e.target.value)} style={inputStyle} />
            </div>
          ))}
          {[
            { label:'Default timezone', val:'Africa/Cairo (UTC+2)' },
            { label:'Default language', val:'English (EN)' },
          ].map((f,i)=>(
            <div key={i}>
              <div style={{ fontSize:10, color:T.muted, marginBottom:6, fontWeight:700, textTransform:'uppercase', letterSpacing:'0.08em' }}>{f.label}</div>
              <input defaultValue={f.val} style={inputStyle} />
            </div>
          ))}
          <div style={{ display:'flex', alignItems:'center', justifyContent:'space-between', paddingTop:4 }}>
            <div>
              <div style={{ fontSize:13, color:T.text, fontWeight:500 }}>Dark mode</div>
              <div style={{ fontSize:11, color:T.muted }}>Enable dark theme for admin console</div>
            </div>
            <Toggle val={darkMode} onToggle={()=>setDarkMode(v=>!v)} />
          </div>
          <div style={{ display:'flex', alignItems:'center', justifyContent:'space-between' }}>
            <div>
              <div style={{ fontSize:13, color:T.text, fontWeight:500 }}>Maintenance mode</div>
              <div style={{ fontSize:11, color:T.muted, maxWidth:380 }}>Takes the app offline. Users will see a maintenance page.</div>
            </div>
            <Toggle val={maint} onToggle={()=>setMaint(v=>!v)} />
          </div>
          {maint && (
            <div style={{ background:`${T.amber}14`, border:`1px solid ${T.amber}40`, borderRadius:8, padding:'10px 14px', fontSize:12, color:T.amber, display:'flex', alignItems:'center', gap:8 }}>
              <AlertTriangle size={14}/>App is currently in maintenance mode. Users cannot access it.
            </div>
          )}
        </div>
      </Card>

      <Card style={{ padding:24 }}>
        <div style={sectionHead}>Notification preferences</div>
        <div style={{ display:'flex', flexDirection:'column', gap:16 }}>
          {[
            { key:'email',  label:'Email alerts',       sub:'Security events, failed payments, new sign-ups' },
            { key:'push',   label:'Push notifications', sub:'Real-time alerts on your admin device'          },
            { key:'sms',    label:'SMS alerts',          sub:'Critical system alerts via SMS'                },
            { key:'digest', label:'Daily digest',        sub:'Summary email every morning at 8 AM'           },
          ].map(n=>(
            <div key={n.key} style={{ display:'flex', alignItems:'center', justifyContent:'space-between' }}>
              <div>
                <div style={{ fontSize:13, color:T.text, fontWeight:500 }}>{n.label}</div>
                <div style={{ fontSize:11, color:T.muted }}>{n.sub}</div>
              </div>
              <Toggle val={notifs[n.key]} onToggle={()=>setNotifs(prev=>({...prev,[n.key]:!prev[n.key]}))} />
            </div>
          ))}
        </div>
      </Card>

      <Card style={{ padding:24 }}>
        <div style={sectionHead}>Integrations</div>
        <div style={{ display:'grid', gridTemplateColumns:'1fr 1fr', gap:10 }}>
          {integrations.map((int)=>(
            <div key={int.name} style={{ display:'flex', alignItems:'center', justifyContent:'space-between', padding:'11px 14px', borderRadius:9, background:T.surf, border:`1px solid ${T.border}` }}>
              <div>
                <div style={{ fontSize:13, fontWeight:600, color:T.text }}>{int.name}</div>
                <div style={{ fontSize:11, color:T.muted }}>{int.desc}</div>
              </div>
              <div style={{ display:'flex', alignItems:'center', gap:8 }}>
                <Badge color={int.connected?T.green:T.muted}>{int.connected?'Connected':'Off'}</Badge>
                <Toggle val={int.connected} onToggle={()=>toggleIntegration(int.name)} />
              </div>
            </div>
          ))}
        </div>
      </Card>

      <div style={{ display:'flex', justifyContent:'flex-end', gap:10 }}>
        <button style={{ padding:'9px 22px', borderRadius:8, background:T.card, border:`1px solid ${T.border}`, color:T.muted, fontSize:13, cursor:'pointer' }}>Discard</button>
        <Btn onClick={handleSave}><Check size={13}/>Save changes</Btn>
      </div>
    </div>
  );
}

// ─── PAGE MAP ─────────────────────────────────────────────────────────────────
const pageMap = {
  dashboard:    DashboardPage,
  users:        UsersPage,
  foods:        FoodPage,
  plans:        PlansPage,
  analytics:    AnalyticsPage,
  notifications:NotificationsPage,
  content:      ContentPage,
  security:     SecurityPage,
  settings:     SettingsPage,
};

// ─── ROOT APP ─────────────────────────────────────────────────────────────────
export default function BiteSmart() {
  const [page, setPage] = useState('dashboard');
  const [collapsed, setCollapsed] = useState(false);

  const PageComponent = pageMap[page];
  const unreadCount = initialNotifications.filter(n=>!n.read).length;

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
            const isNotif = item.id === 'notifications';
            return (
              <button key={item.id} onClick={()=>setPage(item.id)} style={{ width:'100%', display:'flex', alignItems:'center', gap:10, padding:collapsed?'10px 13px':'9px 11px', borderRadius:8, marginBottom:2, background:active?`${T.green}1c`:'none', border:`1px solid ${active?T.green+'40':'transparent'}`, color:active?T.green:T.muted, cursor:'pointer', textAlign:'left', fontSize:13, fontWeight:active?700:400, whiteSpace:'nowrap', overflow:'hidden', justifyContent:collapsed?'center':'flex-start', transition:'background .15s, color .15s', position:'relative' }}
                onMouseEnter={e=>{ if(!active){e.currentTarget.style.background=T.dim+'60';e.currentTarget.style.color=T.text;}}}
                onMouseLeave={e=>{ if(!active){e.currentTarget.style.background='none';e.currentTarget.style.color=T.muted;}}}>
                <item.Icon size={16} style={{ flexShrink:0 }} />
                {!collapsed && <span>{item.label}</span>}
                {isNotif && unreadCount > 0 && (
                  <span style={{ marginLeft:'auto', background:T.red, color:'#fff', fontSize:10, fontWeight:700, borderRadius:20, padding:'1px 6px', flexShrink:0 }}>{unreadCount}</span>
                )}
              </button>
            );
          })}
        </nav>

        <div style={{ padding:'10px 8px', borderTop:`1px solid ${T.border}` }}>
          {!collapsed && (
            <div style={{ display:'flex', alignItems:'center', gap:9, padding:'8px 10px', borderRadius:8, marginBottom:4 }}>
              <div style={{ width:28, height:28, borderRadius:'50%', background:T.glow, border:`1.5px solid ${T.green}40`, display:'flex', alignItems:'center', justifyContent:'center', fontSize:10, fontWeight:800, color:T.green, flexShrink:0 }}>AD</div>
              <div>
                <div style={{ fontSize:12, fontWeight:600, color:T.text, lineHeight:1.2 }}>Admin</div>
                <div style={{ fontSize:10, color:T.muted }}>Super admin</div>
              </div>
            </div>
          )}
          <button style={{ width:'100%', display:'flex', alignItems:'center', gap:10, padding:collapsed?'10px 13px':'8px 11px', borderRadius:8, background:'none', border:'1px solid transparent', color:T.muted, cursor:'pointer', fontSize:12, justifyContent:collapsed?'center':'flex-start' }}
            onMouseEnter={e=>{e.currentTarget.style.color=T.red;}}
            onMouseLeave={e=>{e.currentTarget.style.color=T.muted;}}>
            <LogOut size={15} style={{ flexShrink:0 }} />
            {!collapsed && 'Sign out'}
          </button>
        </div>
      </aside>

      {/* Main */}
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
            {unreadCount > 0 && <span style={{ position:'absolute', top:4, right:4, width:8, height:8, borderRadius:'50%', background:T.red, border:`1.5px solid ${T.surf}`, display:'flex', alignItems:'center', justifyContent:'center', fontSize:8, color:'#fff', fontWeight:700 }}/>}
          </button>
          <div style={{ width:33, height:33, borderRadius:'50%', background:T.glow, border:`2px solid ${T.green}50`, display:'flex', alignItems:'center', justifyContent:'center', fontSize:11, fontWeight:800, color:T.green, flexShrink:0 }}>
            AD
          </div>
        </header>

        <main style={{ flex:1, overflowY:'auto', padding:24, background:T.bg }}>
          <PageComponent />
        </main>
      </div>
    </div>
  );
}
