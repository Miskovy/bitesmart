import { useState, useEffect, useRef } from "react";
import {
  AreaChart, Area, XAxis, YAxis, Tooltip, ResponsiveContainer,
  BarChart, Bar, CartesianGrid
} from "recharts";
import {
  Home, Utensils, MessageSquare, LogOut, Sun, Moon,
  Send, Plus, X, Flame, Droplets, Target, TrendingUp, User,
  Mail, Lock, Eye, EyeOff, Scale, Zap, Star,
  Check, Activity, Bot, Leaf, Shield, Trash2,
  Clock, Sparkles, Camera
} from "lucide-react";

/* ─────────────────────────────────────────────
   CONFIG
───────────────────────────────────────────── */
const BASE = "https://bitesmart-production.up.railway.app/api";

const EP = {
  SIGN_UP: `${BASE}/auth/signup`,
  SIGN_IN: `${BASE}/auth/login`,
  
  // Meals & Daily Logs
  MEALS: `${BASE}/logs`,
  MEAL: (id) => `${BASE}/logs/${id}`,
  GET_SUMMARY: `${BASE}/logs/summary`,
  LOG_WATER: `${BASE}/logs/water`,
  GET_WATER: `${BASE}/logs/water`,
  GET_COMPLETION: `${BASE}/logs/complete`,
  
  // Coach Chat
  CHAT_SESSIONS: `${BASE}/coach/sessions`,
  CHAT_SESSION: (id) => `${BASE}/coach/sessions/${id}`,
  CHAT_HISTORY: (id) => `${BASE}/coach/sessions/${id}/history`,
  CHAT_SEND: `${BASE}/coach/chat`,
  CHAT_STREAM: `${BASE}/coach/chat/stream`,
  
  // AI Vision
  PREDICT: `${BASE}/prediction/ar`,
  CALIBRATE: `${BASE}/prediction/callibration`,
  CORRECT: (id) => `${BASE}/prediction/correct/${id}`,
};

/* ─── Token ─── */
const Token = {
  get: () => localStorage.getItem("bs_token"),
  set: (v) => localStorage.setItem("bs_token", v),
  clear: () => localStorage.removeItem("bs_token"),
};

/* ─── Fetch wrapper ─── */
async function api(url, opts = {}) {
  const tok = Token.get();
  console.log(`[API Request] URL: ${url} | Token retrieved:`, tok);
  
  // Check if the body is FormData (needed for image uploads)
  const isFormData = opts.body instanceof FormData;
  
  const headers = {
    ...(tok ? { Authorization: `Bearer ${tok}` } : {}),
    ...(opts.headers || {}),
  };

  // Only set content-type to JSON if it's not FormData. 
  // For FormData, the browser must automatically set the boundary.
  if (!isFormData && !headers["Content-Type"]) {
    headers["Content-Type"] = "application/json";
  }

  const res = await fetch(url, {
    ...opts,
    headers,
  });
  
  const data = await res.json().catch(() => ({}));
  if (!res.ok) throw new Error(data.message || data.error || `Error ${res.status}`);
  return data;
}

/* ─── Auth ─── */
const AuthAPI = {
  signUp: (name, email, password) =>
    api(EP.SIGN_UP, { method: "POST", body: JSON.stringify({ name, email, password }) }),
  signIn: (email, password) =>
    api(EP.SIGN_IN, { method: "POST", body: JSON.stringify({ email, password }) }),
};

/* ─── Date Helper ─── */
const getTodayDate = () => {
  const d = new Date();
  const year = d.getFullYear();
  const month = String(d.getMonth() + 1).padStart(2, '0');
  const day = String(d.getDate()).padStart(2, '0');
  return `${year}-${month}-${day}`;
};

/* ─── Meals ─── */
const MealsAPI = {
  list: () => api(`${EP.MEALS}?date=${getTodayDate()}`),
  create: (meal) => api(`${EP.MEALS}?date=${getTodayDate()}`, { method: "POST", body: JSON.stringify(meal) }),
  remove: (id) => api(EP.MEAL(id), { method: "DELETE" }),
};

/* ─── Coach Chat ─── */
const CoachAPI = {
  getSessions: () => api(EP.CHAT_SESSIONS),
  deleteSession: (id) => api(EP.CHAT_SESSION(id), { method: "DELETE" }),
  getHistory: (id) => api(EP.CHAT_HISTORY(id)),
  send: (sessionId, msg) => api(EP.CHAT_SEND, {
    method: "POST",
    body: JSON.stringify({ sessionId, message: msg }),
  }),
};

/* ─── AI Vision (Snap & Log) ─── */
const PredictionAPI = {
  predict: (file, plateDiameterCm) => {
    const formData = new FormData();
    formData.append("file", file); 
    formData.append("plate_diameter_cm", plateDiameterCm); 

    return api(EP.CALIBRATE, { method: "POST", body: formData });
  },
  calibrate: (trainingDataId, value) =>
    api(EP.CALIBRATE, { method: "POST", body: JSON.stringify({ trainingDataId, value }) }),
  correct: (trainingDataId, correctLabel) =>
    api(EP.CORRECT(trainingDataId), { method: "PUT", body: JSON.stringify({ correct_label: correctLabel }) }),
};

/* ─── Helpers ─── */
function extractAuth(data) {
  const nested = data?.data || {};
  return {
    token: data?.token || nested.token || data?.access_token || nested.access_token || data?.jwt || nested.jwt || null,
    user: nested.user || data?.user || nested || {},
  };
}

function extractArray(response, keys = []) {
  if (Array.isArray(response)) return response;
  if (!response) return [];
  
  // Handle basic axios/fetch extraction
  const data = response.data || response;
  if (Array.isArray(data)) return data;

  for (const k of keys) {
    if (Array.isArray(data[k])) return data[k];
  }
  
  const nested = data.data || {};
  if (Array.isArray(nested)) return nested;
  for (const k of keys) {
    if (Array.isArray(nested[k])) return nested[k];
  }
  return [];
}

function normalizeMeal(r) {
  if (!r) return null;
  
  // Dig deep to catch relations like r.foodItem
  const nestedFood = r.foodItem || {};

  return {
    id: r.id || r._id || r.logId || Math.random().toString(36).substring(7),
    name: r.name || r.food || r.meal_name || nestedFood.name || "Logged Meal",
    
    // Using explicit Number parsing to block NaN from breaking Recharts component loops
    cal: Math.round(Number(r.cal || r.calories || nestedFood.calories || 0)),
    protein: Math.round(Number(r.protein || r.protein_g || nestedFood.protein || 0)),
    carbs: Math.round(Number(r.carbs || r.carbs_g || nestedFood.carbs || 0)),
    fat: Math.round(Number(r.fat || r.fat_g || r.fats || nestedFood.fat || 0)),
    
    time: r.time || r.logged_at || r.createdAt || new Date().toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" }),
    emoji: r.emoji || "🍽️",
  };
}

function normalizeMsg(r) {
  return {
    role: r.role || (r.sender === "user" ? "user" : "assistant"),
    content: r.content || r.message || r.text || r.coach_response || r.response || "",
  };
}

/* ─── CSS ─── */
const CSS = `
@import url('https://fonts.googleapis.com/css2?family=Syne:wght@400;500;600;700;800&family=DM+Sans:opsz,wght@9..40,300;9..40,400;9..40,500;9..40,600&display=swap');
*,*::before,*::after{box-sizing:border-box}
body{font-family:'DM Sans',sans-serif;margin:0;-webkit-font-smoothing:antialiased;overflow-x:hidden}
.fs{font-family:'Syne',sans-serif!important}
@keyframes fadeUp{from{opacity:0;transform:translateY(22px)}to{opacity:1;transform:translateY(0)}}
@keyframes fadeIn{from{opacity:0}to{opacity:1}}
@keyframes float{0%,100%{transform:translateY(0)}50%{transform:translateY(-10px)}}
@keyframes dotB{0%,100%{transform:translateY(0);opacity:.3}50%{transform:translateY(-5px);opacity:1}}
@keyframes scaleIn{from{opacity:0;transform:scale(.95)}to{opacity:1;transform:scale(1)}}
@keyframes slideR{from{opacity:0;transform:translateX(-14px)}to{opacity:1;transform:translateX(0)}}
@keyframes spin{from{transform:rotate(0deg)}to{transform:rotate(360deg)}}
@keyframes toast{from{opacity:0;transform:translateX(30px)}to{opacity:1;transform:translateX(0)}}
@keyframes pulse{0%,100%{opacity:1}50%{opacity:.4}}
.afu{animation:fadeUp .55s ease both}
.afi{animation:fadeIn .4s ease both}
.asc{animation:scaleIn .3s ease both}
.afl{animation:float 4s ease-in-out infinite}
.asr{animation:slideR .4s ease both}
.s1{animation-delay:.05s}.s2{animation-delay:.1s}.s3{animation-delay:.15s}
.s4{animation-delay:.2s}.s5{animation-delay:.25s}.s6{animation-delay:.3s}
.gd{background:linear-gradient(135deg,#10b981 0%,#22d3ee 50%,#a855f7 100%);-webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text}
.glass{background:rgba(15,23,42,.65);backdrop-filter:blur(20px);-webkit-backdrop-filter:blur(20px);border:1px solid rgba(255,255,255,.07)}
.glass-l{background:rgba(255,255,255,.82);backdrop-filter:blur(20px);-webkit-backdrop-filter:blur(20px);border:1px solid rgba(0,0,0,.08)}
.btn-g{background:linear-gradient(135deg,#10b981,#059669);color:#fff;border:none;cursor:pointer;transition:transform .2s,box-shadow .2s}
.btn-g:hover{transform:translateY(-2px);box-shadow:0 8px 28px rgba(16,185,129,.45)}
.btn-g:active{transform:translateY(0)}
.btn-o{background:transparent;cursor:pointer;transition:all .2s}
.hvup{transition:transform .25s ease,box-shadow .25s ease}
.hvup:hover{transform:translateY(-4px);box-shadow:0 18px 40px rgba(0,0,0,.22)}
.inp{background:rgba(255,255,255,.06);border:1px solid rgba(255,255,255,.1);transition:border-color .2s,background .2s;color:inherit}
.inp:focus{border-color:rgba(16,185,129,.55);background:rgba(255,255,255,.09);outline:none}
.inp-l{background:rgba(0,0,0,.04);border:1px solid rgba(0,0,0,.1);transition:border-color .2s;color:inherit}
.inp-l:focus{border-color:rgba(5,150,105,.5);background:#fff;outline:none}
.slnk{transition:all .2s;border-radius:10px;cursor:pointer}
.slnk:hover{background:rgba(16,185,129,.1)}
.slnk.act{background:rgba(16,185,129,.14)}
.dot1{animation:dotB 1.2s ease infinite 0s}
.dot2{animation:dotB 1.2s ease infinite .2s}
.dot3{animation:dotB 1.2s ease infinite .4s}
.sb{width:7px;height:7px;border-radius:50%;background:#10b981;display:inline-block}
.pbar{height:6px;border-radius:3px;overflow:hidden}
.pfill{height:100%;border-radius:3px;transition:width 1s ease}
::-webkit-scrollbar{width:4px}
::-webkit-scrollbar-track{background:transparent}
::-webkit-scrollbar-thumb{background:rgba(16,185,129,.3);border-radius:2px}
.bubble-u{background:linear-gradient(135deg,#10b981,#059669);border-radius:18px 18px 4px 18px;color:#fff}
.bubble-a{border-radius:18px 18px 18px 4px}
.tanim{animation:toast .3s ease both}
.mesh{background:radial-gradient(ellipse at 15% 50%,rgba(16,185,129,.08) 0%,transparent 55%),radial-gradient(ellipse at 85% 20%,rgba(34,211,238,.06) 0%,transparent 55%),radial-gradient(ellipse at 50% 85%,rgba(168,85,247,.06) 0%,transparent 55%)}
input[type=range]{accent-color:#10b981;width:100%}
.analyzing{animation:pulse 1.2s ease-in-out infinite}
`;

/* ─── Theme ─── */
const T = {
  d: { bg: "#020817", bg2: "#0f172a", t: "#f1f5f9", t2: "#94a3b8", t3: "#475569", bdr: "rgba(255,255,255,.07)", acc: "#10b981", inp: "inp", gl: "glass" },
  l: { bg: "#f0fdf4", bg2: "#f8fafc", t: "#0f172a", t2: "#475569", t3: "#94a3b8", bdr: "rgba(0,0,0,.08)", acc: "#059669", inp: "inp-l", gl: "glass-l" },
};

/* ─── Static data ─── */
const weekCals = [
  { d: "Mon", c: 1850 }, { d: "Tue", c: 2100 }, { d: "Wed", c: 1750 },
  { d: "Thu", c: 1920 }, { d: "Fri", c: 2050 }, { d: "Sat", c: 1600 }, { d: "Sun", c: 1780 },
];
const wtProg = [
  { w: "W1", kg: 82 }, { w: "W2", kg: 81.5 }, { w: "W3", kg: 81.2 }, { w: "W4", kg: 80.8 },
  { w: "W5", kg: 80.1 }, { w: "W6", kg: 79.8 }, { w: "W7", kg: 79.5 }, { w: "W8", kg: 79.2 },
];
const features = [
  { Icon: Bot, title: "AI Nutrition Coach", desc: "24/7 personalized guidance from your AI-powered nutrition expert", color: "#10b981" },
  { Icon: Flame, title: "Calorie Tracking", desc: "Effortlessly log meals and track daily calories and macros", color: "#f59e0b" },
  { Icon: Activity, title: "Progress Analytics", desc: "Beautiful charts to visualize your health journey over time", color: "#22d3ee" },
  { Icon: Scale, title: "BMI Calculator", desc: "Instant BMI with personalized health category and tips", color: "#a855f7" },
  { Icon: Droplets, title: "Hydration Tracker", desc: "Smart reminders and tracking to keep you perfectly hydrated", color: "#3b82f6" },
  { Icon: Target, title: "Goal Setting", desc: "Set milestones and crush them with adaptive AI coaching", color: "#ec4899" },
];
const testimonials = [
  { name: "Sarah Chen", role: "Fitness Enthusiast", quote: "Bite Smart transformed how I think about nutrition. Lost 15 kg in 4 months!", initials: "SC", color: "#10b981" },
  { name: "Marcus Rivera", role: "Marathon Runner", quote: "The AI coaching is incredibly accurate. My race performance improved dramatically.", initials: "MR", color: "#22d3ee" },
  { name: "Priya Patel", role: "Nutritionist", quote: "I recommend Bite Smart to all my clients. The tracking is intuitive and precise.", initials: "PP", color: "#a855f7" },
];
const quickSugg = [
  "How many calories in 100g rice?",
  "High protein breakfast ideas",
  "Benefits of intermittent fasting",
  "1500 calorie meal plan for today",
];

function getBMICat(bmi) {
  if (bmi < 18.5) return { label: "Underweight", color: "#3b82f6", tip: "Consider increasing caloric intake with nutrient-dense foods." };
  if (bmi < 25) return { label: "Normal weight", color: "#10b981", tip: "Great! Maintain your current healthy habits and balanced diet." };
  if (bmi < 30) return { label: "Overweight", color: "#f59e0b", tip: "Small changes in diet and exercise can make a big difference." };
  return { label: "Obese", color: "#ef4444", tip: "Consider consulting a healthcare professional for a personalized plan." };
}

function Spinner({ size = 20, color = "#fff" }) {
  return (
    <div style={{
      width: size, height: size,
      border: `2px solid rgba(255,255,255,.25)`,
      borderTopColor: color,
      borderRadius: "50%",
      animation: "spin .6s linear infinite",
      flexShrink: 0,
    }} />
  );
}

/* ══════════════════════════════════════════════
   TOAST
══════════════════════════════════════════════ */
function Toast({ toasts, dark }) {
  const t = dark ? T.d : T.l;
  return (
    <div style={{ position: "fixed", top: 20, right: 20, zIndex: 9999, display: "flex", flexDirection: "column", gap: 8 }}>
      {toasts.map(x => (
        <div key={x.id} className={`tanim ${t.gl}`} style={{
          padding: "12px 18px", borderRadius: 12, display: "flex", alignItems: "center",
          gap: 10, fontSize: 14, color: t.t, minWidth: 220,
          borderLeft: `3px solid ${x.type === "error" ? "#ef4444" : "#10b981"}`,
        }}>
          {x.type === "error" ? <X size={15} color="#ef4444" /> : <Check size={15} color="#10b981" />}
          {x.msg}
        </div>
      ))}
    </div>
  );
}

/* ══════════════════════════════════════════════
   NAVBAR
══════════════════════════════════════════════ */
function Navbar({ setPage, darkMode, setDarkMode }) {
  const t = darkMode ? T.d : T.l;
  const [scrolled, setScrolled] = useState(false);
  useEffect(() => {
    const h = () => setScrolled(window.scrollY > 20);
    window.addEventListener("scroll", h);
    return () => window.removeEventListener("scroll", h);
  }, []);
  return (
    <nav className={scrolled ? t.gl : ""} style={{
      position: "fixed", top: 0, left: 0, right: 0, zIndex: 100,
      padding: "0 32px", height: 64,
      display: "flex", alignItems: "center", justifyContent: "space-between",
      transition: "all .3s",
    }}>
      <div style={{ display: "flex", alignItems: "center", gap: 10, cursor: "pointer" }} onClick={() => setPage("landing")}>
        <div style={{ width: 34, height: 34, borderRadius: 9, background: "linear-gradient(135deg,#10b981,#059669)", display: "flex", alignItems: "center", justifyContent: "center", boxShadow: "0 4px 14px rgba(16,185,129,.4)" }}>
          <Leaf size={18} color="white" />
        </div>
        <span className="fs" style={{ fontSize: 20, fontWeight: 700, color: t.t }}>Bite<span style={{ color: "#10b981" }}>Smart</span></span>
      </div>
      <div style={{ display: "flex", gap: 8, alignItems: "center" }}>
        <button onClick={() => setDarkMode(!darkMode)} className="btn-o" style={{ padding: 8, borderRadius: 8, border: `1px solid ${t.bdr}`, color: t.t2 }}>
          {darkMode ? <Sun size={17} /> : <Moon size={17} />}
        </button>
        <button onClick={() => setPage("signin")} className="btn-o" style={{ padding: "8px 18px", borderRadius: 8, border: `1px solid ${t.bdr}`, color: t.t, fontSize: 14 }}>Sign In</button>
        <button onClick={() => setPage("signup")} className="btn-g" style={{ padding: "8px 20px", borderRadius: 8, fontSize: 14 }}>Get Started →</button>
      </div>
    </nav>
  );
}

/* ══════════════════════════════════════════════
   LANDING
══════════════════════════════════════════════ */
function LandingPage({ setPage, darkMode }) {
  const t = darkMode ? T.d : T.l;
  return (
    <div style={{ background: t.bg }}>
      <section className="mesh" style={{ minHeight: "100vh", display: "flex", alignItems: "center", justifyContent: "center", padding: "120px 24px 80px", position: "relative", overflow: "hidden" }}>
        <div style={{ position: "absolute", top: "20%", left: "50%", transform: "translateX(-50%)", width: 700, height: 700, background: "radial-gradient(circle,rgba(16,185,129,.08) 0%,transparent 70%)", pointerEvents: "none" }} />
        <div style={{ width: "100%", maxWidth: 1250, margin: "0 auto", position: "relative", zIndex: 1 }}>
          <div style={{ width: "100%", borderRadius: 32, overflow: "hidden", border: `1px solid ${t.bdr}`, background: darkMode ? "rgba(255,255,255,.04)" : "rgba(255,255,255,.75)", backdropFilter: "blur(20px)", boxShadow: "0 30px 80px rgba(0,0,0,.35)", padding: 32 }}>
            <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 40, alignItems: "center" }}>
              <div style={{ textAlign: "left", padding: "10px 20px" }}>
                <div style={{ display: "inline-flex", alignItems: "center", gap: 8, background: "rgba(16,185,129,.12)", border: "1px solid rgba(16,185,129,.25)", borderRadius: 999, padding: "8px 16px", marginBottom: 28 }}>
                  <Sparkles size={14} color="#10b981" />
                  <span style={{ fontSize: 13, color: "#10b981", fontWeight: 600 }}>AI-Powered Nutrition Intelligence</span>
                </div>
                <h1 style={{ fontSize: "clamp(48px,6vw,82px)", lineHeight: 1, fontWeight: 900, color: t.t, marginBottom: 24 }}>
                  Smarter Eating<br /><span style={{ color: "#10b981" }}>Better Living</span>
                </h1>
                <p style={{ fontSize: 17, lineHeight: 1.8, color: t.t2, marginBottom: 36, maxWidth: 520 }}>
                  Smart calorie tracking, AI meal recommendations, personalized nutrition coaching, and powerful insights.
                </p>
                <button onClick={() => setPage("signup")} style={{ padding: "16px 34px", borderRadius: 16, border: "none", background: "#10b981", color: "#000", fontWeight: 700, fontSize: 16, cursor: "pointer" }}>
                  Get Started →
                </button>
                <div style={{ display: "flex", gap: 24, marginTop: 36, flexWrap: "wrap" }}>
                  {[{ icon: <Check size={14} />, label: "Free to start" }, { icon: <Shield size={14} />, label: "Privacy first" }, { icon: <Zap size={14} />, label: "AI-powered" }].map((b, i) => (
                    <div key={i} style={{ display: "flex", alignItems: "center", gap: 6, color: t.t3, fontSize: 13 }}>
                      <span style={{ color: "#10b981" }}>{b.icon}</span>{b.label}
                    </div>
                  ))}
                </div>
              </div>
              <div>
                <img src="/hero-image.jpg" alt="Hero" style={{ width: "100%", height: 680, objectFit: "cover", borderRadius: 28, display: "block" }} />
              </div>
            </div>
          </div>
        </div>
      </section>

      <section style={{ padding: "100px 24px", background: darkMode ? "#0a101f" : t.bg2 }}>
        <div style={{ maxWidth: 1100, margin: "0 auto" }}>
          <div style={{ textAlign: "center", marginBottom: 60 }}>
            <h2 className="fs" style={{ fontSize: "clamp(28px,4vw,46px)", fontWeight: 800, color: t.t, marginBottom: 14 }}>
              Everything you need to<br /><span className="gd">transform your health</span>
            </h2>
          </div>
          <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fit,minmax(300px,1fr))", gap: 20 }}>
            {features.map(({ Icon, title, desc, color }, i) => (
              <div key={i} className={`hvup ${t.gl}`} style={{ padding: "28px 24px", borderRadius: 16, cursor: "pointer" }}>
                <div style={{ width: 48, height: 48, borderRadius: 12, background: `${color}18`, display: "flex", alignItems: "center", justifyContent: "center", marginBottom: 18 }}>
                  <Icon size={22} color={color} />
                </div>
                <h3 className="fs" style={{ fontSize: 17, fontWeight: 700, color: t.t, marginBottom: 8 }}>{title}</h3>
                <p style={{ fontSize: 14, color: t.t2, lineHeight: 1.6, margin: 0 }}>{desc}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      <section style={{ padding: "100px 24px", background: t.bg }}>
        <div style={{ maxWidth: 1000, margin: "0 auto" }}>
          <div style={{ textAlign: "center", marginBottom: 56 }}>
            <h2 className="fs" style={{ fontSize: "clamp(28px,4vw,42px)", fontWeight: 800, color: t.t, marginBottom: 14 }}>
              Loved by <span className="gd">50,000+ users</span>
            </h2>
          </div>
          <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fit,minmax(280px,1fr))", gap: 20 }}>
            {testimonials.map(({ name, role, quote, initials, color }, i) => (
              <div key={i} className={`hvup ${t.gl}`} style={{ padding: "28px 24px", borderRadius: 16 }}>
                <div style={{ display: "flex", gap: 2, marginBottom: 14 }}>
                  {[...Array(5)].map((_, j) => <Star key={j} size={15} fill="#f59e0b" color="#f59e0b" />)}
                </div>
                <p style={{ fontSize: 15, color: t.t2, lineHeight: 1.7, marginBottom: 20 }}>"{quote}"</p>
                <div style={{ display: "flex", alignItems: "center", gap: 12 }}>
                  <div style={{ width: 40, height: 40, borderRadius: "50%", background: `${color}22`, display: "flex", alignItems: "center", justifyContent: "center", fontSize: 13, fontWeight: 700, color }}>{initials}</div>
                  <div>
                    <div style={{ fontWeight: 600, color: t.t, fontSize: 14 }}>{name}</div>
                    <div style={{ fontSize: 12, color: t.t3 }}>{role}</div>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>
    </div>
  );
}

/* ══════════════════════════════════════════════
   AUTH
   ══════════════════════════════════════════════ */
const AuthField = ({ field, placeholder, type = "text", icon, form, setForm, errors, showPw, setShowPw, t }) => (
  <div style={{ position: "relative" }}>
    <div style={{ position: "absolute", left: 14, top: "50%", transform: "translateY(-50%)", color: t.t3 }}>{icon}</div>
    <input
      className={t.inp}
      type={field === "password" ? (showPw ? "text" : "password") : type}
      placeholder={placeholder}
      value={form[field]}
      onChange={e => setForm(p => ({ ...p, [field]: e.target.value }))}
      style={{ width: "100%", padding: "13px 14px 13px 42px", borderRadius: 10, fontSize: 14, fontFamily: "'DM Sans',sans-serif" }}
    />
    {field === "password" && (
      <button onClick={() => setShowPw(p => !p)} className="btn-o"
        style={{ position: "absolute", right: 12, top: "50%", transform: "translateY(-50%)", border: "none", color: t.t3, padding: 4 }}>
        {showPw ? <EyeOff size={16} /> : <Eye size={16} />}
      </button>
    )}
    {errors[field] && <div style={{ fontSize: 12, color: "#ef4444", marginTop: 4, marginLeft: 4 }}>{errors[field]}</div>}
  </div>
);

function AuthPage({ setPage, setAuthed, setCurrentUser, darkMode, isSignup, setDarkMode }) {
  const t = darkMode ? T.d : T.l;
  const [mode, setMode] = useState(isSignup ? "signup" : "signin");
  const [showPw, setShowPw] = useState(false);
  const [loading, setLoading] = useState(false);
  const [form, setForm] = useState({ name: "", email: "", password: "" });
  const [errors, setErrors] = useState({});
  const [apiErr, setApiErr] = useState("");

  const validate = () => {
    const e = {};
    if (mode === "signup" && !form.name.trim()) e.name = "Name is required";
    if (!form.email.includes("@")) e.email = "Valid email required";
    if (form.password.length < 6) e.password = "Min 6 characters";
    setErrors(e);
    return Object.keys(e).length === 0;
  };

  const submit = async () => {
    if (!validate()) return;
    setLoading(true); setApiErr("");
    try {
      let data = mode === "signup"
        ? await AuthAPI.signUp(form.name, form.email, form.password)
        : await AuthAPI.signIn(form.email, form.password);

      console.log("[Auth Submit] Raw API Response:", data);
      let { token, user } = extractAuth(data);
      console.log("[Auth Submit] Extracted Token:", token, "Extracted User:", user);

      if (!token && mode === "signup") {
        const ld = await AuthAPI.signIn(form.email, form.password);
        console.log("[Auth Submit] Signup fallback SignIn Response:", ld);
        const r = extractAuth(ld);
        token = r.token; user = r.user;
        console.log("[Auth Submit] Signup fallback Extracted Token:", token);
      }

      if (token) {
        Token.set(token);
        console.log("[Auth Submit] Token saved to localStorage:", Token.get());
      } else {
        console.warn("[Auth Submit] No token was extracted to save!");
      }
      setCurrentUser(user);
      setAuthed(true);
      setPage("dashboard");
    } catch (err) {
      setApiErr(err.message || "Something went wrong. Please try again.");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="mesh" style={{ minHeight: "100vh", display: "flex", alignItems: "center", justifyContent: "center", padding: 24, background: t.bg, position: "relative" }}>
      <button onClick={() => setPage("landing")} className="btn-o" style={{ position: "absolute", top: 20, left: 20, color: t.t2, fontSize: 14, border: "none", padding: "8px 12px", borderRadius: 8 }}>← Back</button>
      <button onClick={() => setDarkMode(!darkMode)} className="btn-o" style={{ position: "absolute", top: 20, right: 20, padding: 8, borderRadius: 8, border: `1px solid ${t.bdr}`, color: t.t2 }}>
        {darkMode ? <Sun size={17} /> : <Moon size={17} />}
      </button>
      <div className={`asc ${t.gl}`} style={{ width: "100%", maxWidth: 420, borderRadius: 22, padding: "40px 36px" }}>
        <div style={{ textAlign: "center", marginBottom: 32 }}>
          <div style={{ width: 52, height: 52, borderRadius: 14, background: "linear-gradient(135deg,#10b981,#059669)", display: "flex", alignItems: "center", justifyContent: "center", margin: "0 auto 14px", boxShadow: "0 8px 24px rgba(16,185,129,.35)" }}>
            <Leaf size={24} color="white" />
          </div>
          <h1 className="fs" style={{ fontSize: 26, fontWeight: 800, color: t.t, marginBottom: 4 }}>
            {mode === "signup" ? "Create account" : "Welcome back"}
          </h1>
          <p style={{ fontSize: 14, color: t.t2 }}>
            {mode === "signup" ? "Start your health journey today" : "Sign in to your Bite Smart account"}
          </p>
        </div>

        <div style={{ display: "flex", background: darkMode ? "rgba(255,255,255,.05)" : "rgba(0,0,0,.05)", borderRadius: 10, padding: 4, marginBottom: 24 }}>
          {["signin", "signup"].map(m => (
            <button key={m} onClick={() => { setMode(m); setApiErr(""); }} className="btn-o"
              style={{
                flex: 1, padding: "8px", borderRadius: 8, fontSize: 14, fontWeight: 500, border: "none",
                background: mode === m ? (darkMode ? "rgba(255,255,255,.08)" : "#fff") : "transparent",
                color: mode === m ? t.t : t.t3,
                boxShadow: mode === m ? "0 1px 4px rgba(0,0,0,.1)" : "none", transition: "all .2s"
              }}>
              {m === "signin" ? "Sign In" : "Sign Up"}
            </button>
          ))}
        </div>

        <div style={{ display: "flex", flexDirection: "column", gap: 12 }}>
          {mode === "signup" && (
            <AuthField field="name" placeholder="Full name" icon={<User size={16} />} form={form} setForm={setForm} errors={errors} showPw={showPw} setShowPw={setShowPw} t={t} />
          )}
          <AuthField field="email" placeholder="Email address" type="email" icon={<Mail size={16} />} form={form} setForm={setForm} errors={errors} showPw={showPw} setShowPw={setShowPw} t={t} />
          <AuthField field="password" placeholder="Password" icon={<Lock size={16} />} form={form} setForm={setForm} errors={errors} showPw={showPw} setShowPw={setShowPw} t={t} />
        </div>

        {apiErr && (
          <div style={{ marginTop: 12, padding: "10px 14px", borderRadius: 8, background: "rgba(239,68,68,.1)", border: "1px solid rgba(239,68,68,.25)", fontSize: 13, color: "#ef4444" }}>
            {apiErr}
          </div>
        )}

        <button onClick={submit} className="btn-g"
          style={{ width: "100%", padding: "14px", borderRadius: 10, fontSize: 16, fontWeight: 600, marginTop: 20, display: "flex", alignItems: "center", justifyContent: "center", gap: 8 }}>
          {loading ? <Spinner /> : (mode === "signin" ? "Sign In" : "Create Account")}
        </button>

        <p style={{ textAlign: "center", fontSize: 13, color: t.t3, marginTop: 20 }}>
          {mode === "signin" ? "Don't have an account? " : "Already have an account? "}
          <span onClick={() => { setMode(mode === "signin" ? "signup" : "signin"); setApiErr(""); }}
            style={{ color: t.acc, cursor: "pointer", fontWeight: 500 }}>
            {mode === "signin" ? "Sign up free" : "Sign in"}
          </span>
        </p>
      </div>
    </div>
  );
}

/* ══════════════════════════════════════════════
   SIDEBAR
══════════════════════════════════════════════ */
function Sidebar({ page, setPage, setAuthed, darkMode, setDarkMode }) {
  const t = darkMode ? T.d : T.l;
  const links = [
    { id: "dashboard", icon: <Home size={18} />, label: "Dashboard" },
    { id: "tracker", icon: <Utensils size={18} />, label: "Calorie Tracker" },
    { id: "bmi", icon: <Scale size={18} />, label: "BMI Calculator" },
    { id: "chat", icon: <MessageSquare size={18} />, label: "AI Chat" },
  ];
  return (
    <aside style={{ width: 220, minHeight: "100vh", background: t.bg2, borderRight: `1px solid ${t.bdr}`, display: "flex", flexDirection: "column", padding: "0 12px", flexShrink: 0, position: "sticky", top: 0 }}>
      <div style={{ padding: "20px 8px 16px", display: "flex", alignItems: "center", gap: 10, borderBottom: `1px solid ${t.bdr}`, marginBottom: 12 }}>
        <div style={{ width: 32, height: 32, borderRadius: 8, background: "linear-gradient(135deg,#10b981,#059669)", display: "flex", alignItems: "center", justifyContent: "center" }}>
          <Leaf size={16} color="white" />
        </div>
        <span className="fs" style={{ fontSize: 18, fontWeight: 700, color: t.t }}>Bite<span style={{ color: "#10b981" }}>Smart</span></span>
      </div>
      <div style={{ flex: 1, display: "flex", flexDirection: "column", gap: 4 }}>
        {links.map(l => (
          <button key={l.id} onClick={() => setPage(l.id)} className={`slnk ${page === l.id ? "act" : ""}`}
            style={{
              display: "flex", alignItems: "center", gap: 10, padding: "10px 14px", border: "none", background: "transparent",
              color: page === l.id ? t.acc : t.t2, fontSize: 14, fontWeight: page === l.id ? 600 : 400, textAlign: "left",
              borderLeft: page === l.id ? `2px solid ${t.acc}` : "2px solid transparent",
              fontFamily: "'DM Sans',sans-serif", cursor: "pointer"
            }}>
            {l.icon}{l.label}
          </button>
        ))}
      </div>
      <div style={{ borderTop: `1px solid ${t.bdr}`, padding: "12px 0", display: "flex", flexDirection: "column", gap: 4 }}>
        <button onClick={() => setDarkMode(!darkMode)} className="slnk btn-o"
          style={{ display: "flex", alignItems: "center", gap: 10, padding: "10px 14px", border: "none", background: "transparent", color: t.t2, fontSize: 14, fontFamily: "'DM Sans',sans-serif" }}>
          {darkMode ? <Sun size={18} /> : <Moon size={18} />}
          {darkMode ? "Light Mode" : "Dark Mode"}
        </button>
        <button onClick={() => { Token.clear(); setAuthed(false); setPage("landing"); }} className="slnk btn-o"
          style={{ display: "flex", alignItems: "center", gap: 10, padding: "10px 14px", border: "none", background: "transparent", color: "#ef4444", fontSize: 14, fontFamily: "'DM Sans',sans-serif" }}>
          <LogOut size={18} />Sign Out
        </button>
      </div>
    </aside>
  );
}

/* ══════════════════════════════════════════════
   DASHBOARD
══════════════════════════════════════════════ */
function Dashboard({ darkMode, currentUser }) {
  const t = darkMode ? T.d : T.l;
  const [water, setWater] = useState(6);
  const name = currentUser?.name || currentUser?.full_name || currentUser?.username || "there";

  const cards = [
    { icon: <Flame size={20} />, label: "Calories Today", val: "1,780", sub: "of 2,000 goal", color: "#f59e0b", pct: 89 },
    { icon: <Activity size={20} />, label: "Active Minutes", val: "42", sub: "of 60 goal", color: "#10b981", pct: 70 },
    { icon: <Droplets size={20} />, label: "Water Intake", val: `${water} glasses`, sub: "of 8 goal", color: "#3b82f6", pct: Math.round(water / 8 * 100) },
    { icon: <TrendingUp size={20} />, label: "Weight", val: "79.2 kg", sub: "−2.8 kg this month", color: "#a855f7", pct: 72 },
  ];

  return (
    <div style={{ flex: 1, padding: "32px 28px", overflowY: "auto", background: t.bg, minHeight: "100vh" }}>
      <div className="afu" style={{ marginBottom: 28 }}>
        <h1 className="fs" style={{ fontSize: 26, fontWeight: 800, color: t.t, margin: "0 0 4px" }}>Good morning, {name} 👋</h1>
        <p style={{ color: t.t2, fontSize: 15, margin: 0 }}>Here's your health overview for today</p>
      </div>

      <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fit,minmax(200px,1fr))", gap: 16, marginBottom: 24 }}>
        {cards.map(({ icon, label, val, sub, color, pct }, i) => (
          <div key={i} className={`${t.gl} hvup`} style={{ borderRadius: 16, padding: "20px" }}>
            <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start", marginBottom: 12 }}>
              <div style={{ width: 40, height: 40, borderRadius: 10, background: `${color}18`, display: "flex", alignItems: "center", justifyContent: "center", color }}>{icon}</div>
              <span style={{ fontSize: 12, color, background: `${color}18`, padding: "3px 8px", borderRadius: 20, fontWeight: 500 }}>{pct}%</span>
            </div>
            <div className="fs" style={{ fontSize: 24, fontWeight: 700, color: t.t, marginBottom: 2 }}>{val}</div>
            <div style={{ fontSize: 12, color: t.t3, marginBottom: 10 }}>{label}</div>
            <div className="pbar" style={{ background: darkMode ? "rgba(255,255,255,.08)" : "rgba(0,0,0,.08)" }}>
              <div className="pfill" style={{ width: `${pct}%`, background: color }} />
            </div>
            <div style={{ fontSize: 11, color: t.t3, marginTop: 4 }}>{sub}</div>
          </div>
        ))}
      </div>

      <div style={{ display: "grid", gridTemplateColumns: "1.5fr 1fr", gap: 20, marginBottom: 20 }}>
        <div className={`${t.gl}`} style={{ borderRadius: 16, padding: "20px" }}>
          <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 20 }}>
            <div>
              <h3 className="fs" style={{ fontSize: 16, fontWeight: 700, color: t.t, margin: 0 }}>Weekly Calories</h3>
              <p style={{ fontSize: 12, color: t.t3, margin: "4px 0 0" }}>Daily intake vs 2,000 cal goal</p>
            </div>
            <div style={{ fontSize: 12, color: "#10b981", background: "rgba(16,185,129,.12)", padding: "4px 10px", borderRadius: 20 }}>This week</div>
          </div>
          <ResponsiveContainer width="100%" height={180}>
            <BarChart data={weekCals} margin={{ top: 0, right: 0, left: -20, bottom: 0 }}>
              <CartesianGrid strokeDasharray="3 3" stroke={darkMode ? "rgba(255,255,255,.05)" : "rgba(0,0,0,.06)"} vertical={false} />
              <XAxis dataKey="d" tick={{ fontSize: 11, fill: t.t3 }} axisLine={false} tickLine={false} />
              <YAxis tick={{ fontSize: 11, fill: t.t3 }} axisLine={false} tickLine={false} />
              <Tooltip contentStyle={{ background: t.bg2, border: `1px solid ${t.bdr}`, borderRadius: 10, color: t.t, fontSize: 12 }} />
              <Bar dataKey="c" fill="#10b981" radius={[6, 6, 0, 0]} opacity={0.85} />
            </BarChart>
          </ResponsiveContainer>
        </div>

        <div className={`${t.gl}`} style={{ borderRadius: 16, padding: "20px" }}>
          <h3 className="fs" style={{ fontSize: 16, fontWeight: 700, color: t.t, margin: "0 0 4px" }}>Weight Progress</h3>
          <p style={{ fontSize: 12, color: t.t3, margin: "0 0 16px" }}>8-week journey</p>
          <ResponsiveContainer width="100%" height={180}>
            <AreaChart data={wtProg} margin={{ top: 5, right: 0, left: -25, bottom: 0 }}>
              <defs>
                <linearGradient id="wg" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="5%" stopColor="#a855f7" stopOpacity={0.25} />
                  <stop offset="95%" stopColor="#a855f7" stopOpacity={0} />
                </linearGradient>
              </defs>
              <CartesianGrid strokeDasharray="3 3" stroke={darkMode ? "rgba(255,255,255,.05)" : "rgba(0,0,0,.06)"} vertical={false} />
              <XAxis dataKey="w" tick={{ fontSize: 11, fill: t.t3 }} axisLine={false} tickLine={false} />
              <YAxis tick={{ fontSize: 11, fill: t.t3 }} axisLine={false} tickLine={false} domain={["auto", "auto"]} />
              <Tooltip contentStyle={{ background: t.bg2, border: `1px solid ${t.bdr}`, borderRadius: 10, color: t.t, fontSize: 12 }} />
              <Area type="monotone" dataKey="kg" stroke="#a855f7" strokeWidth={2.5} fill="url(#wg)" dot={false} />
            </AreaChart>
          </ResponsiveContainer>
        </div>
      </div>

      <div style={{ display: "grid", gridTemplateColumns: "1fr 1.5fr", gap: 20 }}>
        <div className={`${t.gl}`} style={{ borderRadius: 16, padding: "20px" }}>
          <h3 className="fs" style={{ fontSize: 16, fontWeight: 700, color: t.t, margin: "0 0 16px" }}>Hydration</h3>
          <div style={{ display: "flex", flexWrap: "wrap", gap: 8, marginBottom: 16 }}>
            {[...Array(8)].map((_, i) => (
              <button key={i} onClick={() => setWater(i < water ? i : i + 1)} className="btn-o"
                style={{
                  width: 36, height: 36, borderRadius: 10, border: "none", fontSize: 18, cursor: "pointer",
                  background: i < water ? "rgba(59,130,246,.2)" : "rgba(255,255,255,.06)",
                  transition: "all .2s", transform: i < water ? "scale(1.08)" : "scale(1)"
                }}>
                💧
              </button>
            ))}
          </div>
          <p style={{ fontSize: 13, color: t.t3, margin: 0 }}>{water} of 8 glasses — {Math.round(water * 250)}ml</p>
        </div>

        <div className={`${t.gl}`} style={{ borderRadius: 16, padding: "20px" }}>
          <h3 className="fs" style={{ fontSize: 16, fontWeight: 700, color: t.t, margin: "0 0 16px" }}>Today's Macros</h3>
          <div style={{ display: "flex", flexDirection: "column", gap: 12 }}>
            {[
              { label: "Protein", val: 82, goal: 120, color: "#22d3ee", unit: "g" },
              { label: "Carbs", val: 210, goal: 250, color: "#f59e0b", unit: "g" },
              { label: "Fats", val: 54, goal: 65, color: "#a855f7", unit: "g" },
            ].map(m => (
              <div key={m.label}>
                <div style={{ display: "flex", justifyContent: "space-between", marginBottom: 6, fontSize: 13 }}>
                  <span style={{ color: t.t2 }}>{m.label}</span>
                  <span style={{ color: t.t, fontWeight: 500 }}>{m.val}<span style={{ color: t.t3 }}>/{m.goal}{m.unit}</span></span>
                </div>
                <div className="pbar" style={{ background: darkMode ? "rgba(255,255,255,.08)" : "rgba(0,0,0,.08)" }}>
                  <div className="pfill" style={{ width: `${Math.min(m.val / m.goal * 100, 100)}%`, background: m.color }} />
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
/* ══════════════════════════════════════════════
   BMI CALCULATOR
══════════════════════════════════════════════ */
function BMICalculator({ darkMode }) {
  const t = darkMode ? T.d : T.l;
  const [weight, setWeight] = useState(70);
  const [height, setHeight] = useState(175);

  // Calculate BMI: weight (kg) / (height (m) * height (m))
  const bmi = (weight / Math.pow(height / 100, 2)).toFixed(1);
  const cat = getBMICat(bmi); // This uses the helper function already in your file!

  return (
    <div style={{ flex: 1, padding: "32px 28px", background: t.bg, minHeight: "100vh" }}>
      <div className="afu" style={{ marginBottom: 24 }}>
        <h1 className="fs" style={{ fontSize: 26, fontWeight: 800, color: t.t, margin: "0 0 4px" }}>BMI Calculator</h1>
        <p style={{ color: t.t2, fontSize: 15, margin: 0 }}>Check your Body Mass Index and health category</p>
      </div>

      <div className={`asc ${t.gl}`} style={{ borderRadius: 16, padding: "32px", maxWidth: 500, margin: "0 auto", marginTop: 40 }}>
        
        {/* Weight Slider */}
        <div style={{ marginBottom: 32 }}>
          <div style={{ display: "flex", justifyContent: "space-between", marginBottom: 12 }}>
            <label style={{ color: t.t2, fontSize: 15, fontWeight: 500 }}>Weight (kg)</label>
            <span className="fs" style={{ color: t.t, fontWeight: 700, fontSize: 18 }}>{weight} kg</span>
          </div>
          <input type="range" min="30" max="150" value={weight} onChange={e => setWeight(e.target.value)} 
            style={{ width: "100%", accentColor: "#10b981", cursor: "pointer" }} />
        </div>

        {/* Height Slider */}
        <div style={{ marginBottom: 40 }}>
          <div style={{ display: "flex", justifyContent: "space-between", marginBottom: 12 }}>
            <label style={{ color: t.t2, fontSize: 15, fontWeight: 500 }}>Height (cm)</label>
            <span className="fs" style={{ color: t.t, fontWeight: 700, fontSize: 18 }}>{height} cm</span>
          </div>
          <input type="range" min="120" max="220" value={height} onChange={e => setHeight(e.target.value)} 
            style={{ width: "100%", accentColor: "#10b981", cursor: "pointer" }} />
        </div>

        {/* Results Card */}
        <div style={{ textAlign: "center", padding: "32px 24px", borderRadius: 16, background: darkMode ? "rgba(0,0,0,.2)" : "rgba(0,0,0,.03)", border: `1px solid ${t.bdr}` }}>
          <div style={{ fontSize: 13, color: t.t2, marginBottom: 8, textTransform: "uppercase", letterSpacing: 1 }}>Your BMI is</div>
          <div className="fs" style={{ fontSize: 56, fontWeight: 800, color: cat.color, lineHeight: 1 }}>{bmi}</div>
          
          <div style={{ display: "inline-block", padding: "6px 16px", borderRadius: 20, background: `${cat.color}22`, color: cat.color, fontSize: 14, fontWeight: 700, marginTop: 16, marginBottom: 12 }}>
            {cat.label}
          </div>
          
          <p style={{ fontSize: 14, color: t.t3, margin: 0, lineHeight: 1.6 }}>{cat.tip}</p>
        </div>
      </div>
    </div>
  );
}
/* ══════════════════════════════════════════════
   CALORIE TRACKER + SNAP & LOG (USING PREDICTION API)
══════════════════════════════════════════════ */


/* ══════════════════════════════════════════════
   CALORIE TRACKER + SNAP & LOG
══════════════════════════════════════════════ */
function CalorieTracker({ darkMode, addToast, MealsAPI, PredictionAPI, extractArray, normalizeMeal, T }) {
  const t = darkMode ? T.d : T.l;
  const [meals, setMeals] = useState([]);
  const [loading, setLoading] = useState(true);
  const [showForm, setShowForm] = useState(false);
  const [saving, setSaving] = useState(false);
  const [newMeal, setNewMeal] = useState({ name: "", cal: "", protein: "", carbs: "", fat: "", time: "" });
  
  // Snap & Log State
  const [snapMode, setSnapMode] = useState(false);
  const [snapImg, setSnapImg] = useState(null);
  const [snapFile, setSnapFile] = useState(null); 
  const [plateDiameter, setPlateDiameter] = useState(""); 
  const [analyzing, setAnalyzing] = useState(false);
  const [snapRes, setSnapRes] = useState(null);
  
  // Replace fileRef with two separate refs for Camera and Gallery
  const cameraRef = useRef(null);
  const galleryRef = useRef(null);
  
  const [mealType, setMealType] = useState("Lunch"); 
  const [quantity, setQuantity] = useState(1);       

  // Correction & Calibration State
  const [showCorrect, setShowCorrect] = useState(false);
  const [correctLabel, setCorrectLabel] = useState("");
  const [showCalibrate, setShowCalibrate] = useState(false);
  const [calibData, setCalibData] = useState("");

  const GOAL = 2000;
  const totals = {
    cal: meals.reduce((a, m) => a + m.cal, 0),
    protein: meals.reduce((a, m) => a + m.protein, 0),
    carbs: meals.reduce((a, m) => a + m.carbs, 0),
    fat: meals.reduce((a, m) => a + m.fat, 0),
  };

  useEffect(() => {
    (async () => {
      try {
        const data = await MealsAPI.list();
        const raw = extractArray(data, ["meals", "items", "logs", "mealLogs"]);
        
        // Safely parse values and drop anything that returns undefined or null references
        const validatedMeals = raw.map(normalizeMeal).filter(m => m !== null && !!m.id);
        setMeals(validatedMeals);
      } catch (err) {
        addToast("Couldn't load meals — " + err.message, "error");
      } finally {
        setLoading(false);
      }
    })();
  }, []);

  const doAdd = async (src) => {
    if (!src.mealType || !src.quantity) {
      addToast("Please select meal type and quantity!", "error");
      return;
    }

    // 🚨 PASTE THE VALID ID YOU COPIED FROM APIDOG BETWEEN THESE QUOTES 🚨
    const VALID_DB_FOOD_ID = "PASTE_YOUR_VALID_FOOD_ID_HERE";

    setSaving(true);
    try {
      const payload = {
        // We force it to use a real ID that exists in your food items table
        foodItemId: VALID_DB_FOOD_ID,
        
        mealType: src.mealType, 
        quantity: parseFloat(src.quantity), 
        name: src.name, // The UI will still show the AI's name (e.g., Falafel)
        cal: +src.cal,  // The UI will still track the AI's calories
        protein: +(src.protein || 0),
        carbs: +(src.carbs || 0),
        fat: +(src.fat || 0),
        time: src.time || new Date().toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" }),
        emoji: src.emoji || "🍽️",
      };
      
      const created = await MealsAPI.create(payload);
      setMeals(p => [...p, normalizeMeal(created)]);
      
      // Clear forms
      setNewMeal({ name: "", cal: "", protein: "", carbs: "", fat: "", time: "" });
      setShowForm(false);
      setSnapMode(false); setSnapImg(null); setSnapFile(null); setSnapRes(null); setPlateDiameter("");
      setShowCorrect(false); setShowCalibrate(false);
      
      addToast(`${payload.name} added to your logs!`);
    } catch (err) {
      addToast("Failed to add meal — " + err.message, "error");
    } finally {
      setSaving(false);
    }
  };

  const doDelete = async (id) => {
    const prev = meals;
    setMeals(p => p.filter(m => m.id !== id));
    try {
      await MealsAPI.remove(id);
      addToast("Meal removed");
    } catch (err) {
      setMeals(prev);
      addToast("Failed to remove — " + err.message, "error");
    }
  };

  const onPick = (e) => {
    const file = e.target.files[0];
    if (!file) return;
    setSnapRes(null); setShowCorrect(false); setShowCalibrate(false);
    setSnapFile(file); 
    
    const reader = new FileReader();
    reader.onload = ev => {
      setSnapImg(ev.target.result); 
    };
    reader.readAsDataURL(file);
  };

  const runVision = async () => {
    if (!snapFile) return;
    
    if (!plateDiameter) {
      addToast("Please enter the plate diameter in cm first!", "error");
      return;
    }

    setAnalyzing(true); setSnapRes(null);
    
    try {
      const rawData = await PredictionAPI.predict(snapFile, plateDiameter); 
      const actualResult = rawData?.data?.data || rawData?.data || rawData;
      const getNum = (val1, val2, val3) => Math.round(Number(val1 || val2 || val3 || 0));

     setSnapRes({
        name: actualResult?.food_detected || actualResult?.meal_name || "Detected Meal",
        cal: getNum(actualResult?.macros?.calories, actualResult?.calories, actualResult?.cal),
        protein: getNum(actualResult?.macros?.protein_g, actualResult?.protein_g, actualResult?.protein),
        carbs: getNum(actualResult?.macros?.carbs_g, actualResult?.carbs_g, actualResult?.carbs),
        fat: getNum(actualResult?.macros?.fats_g, actualResult?.fats_g, actualResult?.fat),
        emoji: "🍽️", 
        // 👇 ADDED: actualResult?.training_data_id is now first in line!
        trainingDataId: actualResult?.training_data_id || actualResult?.trainingDataId || actualResult?.id 
      });
    } catch (err) {
      addToast("Analysis failed — " + err.message, "error");
    } finally {
      setAnalyzing(false);
    }
  };

  const submitCorrection = async () => {
    if (!correctLabel || !snapRes?.trainingDataId) return;
    try {
      await PredictionAPI.correct(snapRes.trainingDataId, correctLabel);
      addToast("Correction submitted. Thank you!");
      setShowCorrect(false); setCorrectLabel("");
    } catch (err) {
      addToast("Correction failed — " + err.message, "error");
    }
  };

  const submitCalibration = async () => {
    if (!calibData || !snapRes?.trainingDataId) return;
    try {
      await PredictionAPI.calibrate(snapRes.trainingDataId, calibData);
      addToast("Calibration submitted.");
      setShowCalibrate(false); setCalibData("");
    } catch (err) {
      addToast("Calibration failed — " + err.message, "error");
    }
  };

  const fi = (field, ph) => (
    <input className={t.inp} placeholder={ph} value={newMeal[field]}
      onChange={e => setNewMeal(p => ({ ...p, [field]: e.target.value }))}
      style={{ padding: "10px 12px", borderRadius: 8, fontSize: 13, width: "100%", fontFamily: "'DM Sans',sans-serif" }} />
  );

  if (loading) return (
    <div style={{ flex: 1, display: "flex", alignItems: "center", justifyContent: "center", background: t.bg, minHeight: "100vh" }}>
      <div style={{ textAlign: "center", color: t.t2 }}>
        <div style={{ width: 32, height: 32, border: "3px solid rgba(16,185,129,.3)", borderTopColor: "#10b981", borderRadius: "50%", animation: "spin .7s linear infinite", margin: "0 auto 14px" }} />
        Loading meals…
      </div>
    </div>
  );

  return (
    <div style={{ flex: 1, padding: "32px 28px", background: t.bg, minHeight: "100vh" }}>
      <div className="afu" style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start", marginBottom: 24 }}>
        <div>
          <h1 className="fs" style={{ fontSize: 26, fontWeight: 800, color: t.t, margin: "0 0 4px" }}>Calorie Tracker</h1>
          <p style={{ color: t.t2, fontSize: 15, margin: 0 }}>Log meals and track your daily nutrition</p>
        </div>
        <div style={{ display: "flex", gap: 8 }}>
          <button onClick={() => { setSnapMode(p => !p); setShowForm(false); setSnapImg(null); setSnapRes(null); setSnapFile(null); }}
            className="btn-o"
            style={{
              padding: "10px 16px", borderRadius: 10, fontSize: 14, display: "flex", alignItems: "center", gap: 8,
              border: `1px solid ${snapMode ? "#10b981" : t.bdr}`,
              color: snapMode ? "#10b981" : t.t2,
              background: snapMode ? "rgba(16,185,129,.08)" : "transparent"
            }}>
            <Camera size={16} />Snap & Log
          </button>
          <button onClick={() => { setShowForm(p => !p); setSnapMode(false); }} className="btn-g"
            style={{ padding: "10px 20px", borderRadius: 10, fontSize: 14, display: "flex", alignItems: "center", gap: 8 }}>
            <Plus size={16} />{showForm ? "Cancel" : "Add Meal"}
          </button>
        </div>
      </div>

      {/* Summary */}
      <div style={{ display: "grid", gridTemplateColumns: "repeat(4,1fr)", gap: 14, marginBottom: 20 }}>
        {[
          { l: "Calories", v: totals.cal, goal: GOAL, u: "kcal", c: "#10b981" },
          { l: "Protein", v: totals.protein, goal: 120, u: "g", c: "#22d3ee" },
          { l: "Carbs", v: totals.carbs, goal: 250, u: "g", c: "#f59e0b" },
          { l: "Fats", v: totals.fat, goal: 65, u: "g", c: "#a855f7" },
        ].map(({ l, v, goal, u, c }, i) => (
          <div key={i} className={t.gl} style={{ borderRadius: 14, padding: "16px" }}>
            <div style={{ fontSize: 12, color: t.t3, marginBottom: 4 }}>{l}</div>
            <div className="fs" style={{ fontSize: 22, fontWeight: 700, color: c, marginBottom: 2 }}>
              {v}<span style={{ fontSize: 12, color: t.t3, fontWeight: 400 }}>/{goal}{u}</span>
            </div>
            <div className="pbar" style={{ background: darkMode ? "rgba(255,255,255,.08)" : "rgba(0,0,0,.08)", marginTop: 8, height: 6, borderRadius: 3 }}>
              <div className="pfill" style={{ width: `${Math.min(v / goal * 100, 100)}%`, background: c, height: "100%", borderRadius: 3 }} />
            </div>
          </div>
        ))}
      </div>

      {/* Snap & Log Area */}
      {snapMode && (
        <div className={`asc ${t.gl}`} style={{ borderRadius: 16, padding: "24px", marginBottom: 20 }}>
          <div style={{ display: "flex", alignItems: "center", gap: 10, marginBottom: 20 }}>
            <div style={{ width: 36, height: 36, borderRadius: 10, background: "rgba(16,185,129,.12)", display: "flex", alignItems: "center", justifyContent: "center" }}>
              <Camera size={18} color="#10b981" />
            </div>
            <div>
              <h3 className="fs" style={{ fontSize: 16, fontWeight: 700, color: t.t, margin: 0 }}>Snap & Log</h3>
              <p style={{ fontSize: 12, color: t.t3, margin: 0 }}>Photo your food — AI estimates the calories instantly</p>
            </div>
          </div>

          <div style={{
              border: `2px dashed ${snapImg ? "#10b981" : t.bdr}`, borderRadius: 14, 
              minHeight: snapImg ? 0 : 160, display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center",
              marginBottom: 16, transition: "border-color .2s", overflow: "hidden", padding: snapImg ? 0 : 24
            }}>
            {snapImg ? (
              <img src={snapImg} alt="Food" style={{ width: "100%", maxHeight: 280, objectFit: "cover", borderRadius: 12, display: "block" }} />
            ) : (
              <>
                <Camera size={32} color={t.t3} style={{ marginBottom: 10 }} />
                <p style={{ color: t.t3, fontSize: 14, margin: "0 0 16px" }}>Upload or take a photo of your food</p>
                
                {/* Two explicit buttons for Camera and Gallery */}
                <div style={{ display: "flex", gap: 12 }}>
                  <button onClick={() => cameraRef.current?.click()} className="btn-o" style={{ padding: "8px 16px", borderRadius: 8, fontSize: 13, border: `1px solid ${t.bdr}`, color: t.t, background: "transparent" }}>
                    Take Photo
                  </button>
                  <button onClick={() => galleryRef.current?.click()} className="btn-o" style={{ padding: "8px 16px", borderRadius: 8, fontSize: 13, border: `1px solid ${t.bdr}`, color: t.t, background: "transparent" }}>
                    Upload File
                  </button>
                </div>
              </>
            )}
          </div>
          
          {/* Two hidden inputs: One forces camera, one allows file picking */}
          <input ref={cameraRef} type="file" accept="image/*" capture="environment" onChange={onPick} style={{ display: "none" }} />
          <input ref={galleryRef} type="file" accept="image/*" onChange={onPick} style={{ display: "none" }} />

          {snapImg && !snapRes && (
            <>
              <div style={{ marginBottom: 16, display: "flex", alignItems: "center", gap: 10 }}>
                <label style={{ color: t.t2, fontSize: 13, fontWeight: 500 }}>
                  Plate Diameter (cm):
                </label>
                <input 
                  type="number" 
                  placeholder="e.g. 20"
                  value={plateDiameter} 
                  onChange={(e) => setPlateDiameter(e.target.value)}
                  className={t.inp}
                  style={{ flex: 1, padding: "10px 12px", borderRadius: 8, border: `1px solid ${t.bdr}`, background: "transparent", color: t.t }}
                />
              </div>

              <button onClick={runVision} disabled={analyzing} className="btn-g"
                style={{ width: "100%", padding: "12px", borderRadius: 10, fontSize: 15, fontWeight: 600, display: "flex", alignItems: "center", justifyContent: "center", gap: 10, marginBottom: 16, opacity: analyzing ? .7 : 1 }}>
                {analyzing
                  ? <span>Analyzing food...</span>
                  : <><Sparkles size={17} />Identify & Get Calories</>}
              </button>
            </>
          )}

          {snapRes && (
            <div className="asc" style={{ borderRadius: 12, padding: "18px 20px", background: darkMode ? "rgba(16,185,129,.08)" : "rgba(16,185,129,.06)", border: "1px solid rgba(16,185,129,.2)", marginBottom: 16 }}>
              <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start", marginBottom: 14 }}>
                <div style={{ display: "flex", alignItems: "center", gap: 10 }}>
                  <span style={{ fontSize: 32 }}>{snapRes.emoji}</span>
                  <div>
                    <div style={{ fontWeight: 700, color: t.t, fontSize: 16 }}>{snapRes.name}</div>
                    <div style={{ fontSize: 12, color: t.t3 }}>AI estimated</div>
                  </div>
                </div>
                <div className="fs" style={{ fontSize: 28, fontWeight: 800, color: "#10b981" }}>
                  {snapRes.cal}<span style={{ fontSize: 13, fontWeight: 400, color: t.t3 }}> kcal</span>
                </div>
              </div>
              
              <div style={{ display: "flex", gap: 12, marginBottom: 20 }}>
                {[{ l: "Protein", v: snapRes.protein, c: "#22d3ee" }, { l: "Carbs", v: snapRes.carbs, c: "#f59e0b" }, { l: "Fat", v: snapRes.fat, c: "#a855f7" }].map(m => (
                  <div key={m.l} style={{ flex: 1, borderRadius: 8, padding: "10px", background: darkMode ? "rgba(255,255,255,.05)" : "rgba(0,0,0,.04)", textAlign: "center" }}>
                    <div style={{ fontSize: 18, fontWeight: 700, color: m.c }}>{m.v}g</div>
                    <div style={{ fontSize: 11, color: t.t3 }}>{m.l}</div>
                  </div>
                ))}
              </div>

              {/* NEW: Meal Type & Quantity selectors before saving */}
              <div style={{ display: "flex", gap: 10, marginBottom: 16 }}>
                          <select 
                            className={t.inp} 
                            value={mealType} 
                            onChange={e => setMealType(e.target.value)} 
                            style={{flex: 1, padding: "10px 12px", borderRadius: 8, border: `1px solid ${t.bdr}`, background: darkMode ? "rgba(0,0,0,0.2)" : "#fff", color: t.t}}
                          >
                            <option value="Breakfast">Breakfast</option>
                            <option value="Lunch">Lunch</option>
                            <option value="Dinner">Dinner</option>
                            <option value="Snack">Snack</option>
                          </select>
                <input 
                  type="number" 
                  value={quantity} 
                  onChange={e => setQuantity(e.target.value)} 
                  min="0.1" step="0.1" placeholder="Qty"
                  className={t.inp} 
                  style={{width: 70, padding: "10px", borderRadius: 8, border: `1px solid ${t.bdr}`, background: darkMode ? "rgba(0,0,0,0.2)" : "#fff", color: t.t}} 
                />
              </div>

              <div style={{ display: "flex", gap: 8, flexWrap: "wrap", marginBottom: 12 }}>
                {/* Note how we inject mealType and quantity into the doAdd function here! */}
                <button onClick={() => doAdd({ ...snapRes, mealType, quantity })} disabled={saving} className="btn-g"
                  style={{ flex: 2, padding: "11px", borderRadius: 9, fontSize: 14, fontWeight: 600, display: "flex", alignItems: "center", justifyContent: "center", gap: 8 }}>
                  {saving ? <span>Saving...</span> : <><Check size={15} />Add to Log</>}
                </button>
                <button onClick={() => { setSnapImg(null); setSnapRes(null); setSnapFile(null); setShowCorrect(false); setShowCalibrate(false); }} className="btn-o"
                  style={{ flex: 1, padding: "11px 16px", borderRadius: 9, border: `1px solid ${t.bdr}`, color: t.t2, fontSize: 14 }}>
                  Retake
                </button>
              </div>

              <div style={{ display: "flex", gap: 8, marginTop: 8 }}>
                <button onClick={() => { setShowCorrect(!showCorrect); setShowCalibrate(false); }} className="btn-o" style={{ flex: 1, padding: "8px", borderRadius: 6, fontSize: 12, color: t.t3, background: "transparent", border: `1px dashed ${t.bdr}` }}>
                  Wrong food? Correct it
                </button>
                <button onClick={() => { setShowCalibrate(!showCalibrate); setShowCorrect(false); }} className="btn-o" style={{ flex: 1, padding: "8px", borderRadius: 6, fontSize: 12, color: t.t3, background: "transparent", border: `1px dashed ${t.bdr}` }}>
                  Adjust Portion / Calibrate
                </button>
              </div>

              {showCorrect && (
                <div style={{ marginTop: 12, padding: 12, borderRadius: 8, background: darkMode ? "rgba(0,0,0,.2)" : "#fff", border: `1px solid ${t.bdr}` }}>
                  <p style={{ fontSize: 12, margin: "0 0 8px", color: t.t2 }}>Enter the correct food name to train the AI:</p>
                  <div style={{ display: "flex", gap: 8 }}>
                    <input className={t.inp} value={correctLabel} onChange={e => setCorrectLabel(e.target.value)} placeholder="e.g. Chicken Salad" style={{ flex: 1, padding: "8px 12px", borderRadius: 6, fontSize: 13, border: `1px solid ${t.bdr}`, background: "transparent", color: t.t }} />
                    <button onClick={submitCorrection} className="btn-g" style={{ padding: "0 14px", borderRadius: 6, fontSize: 13, fontWeight: 600 }}>Submit</button>
                  </div>
                </div>
              )}

              {showCalibrate && (
                <div style={{ marginTop: 12, padding: 12, borderRadius: 8, background: darkMode ? "rgba(0,0,0,.2)" : "#fff", border: `1px solid ${t.bdr}` }}>
                  <p style={{ fontSize: 12, margin: "0 0 8px", color: t.t2 }}>Enter actual weight/volume to calibrate:</p>
                  <div style={{ display: "flex", gap: 8 }}>
                    <input className={t.inp} value={calibData} onChange={e => setCalibData(e.target.value)} placeholder="e.g. 200g" style={{ flex: 1, padding: "8px 12px", borderRadius: 6, fontSize: 13, border: `1px solid ${t.bdr}`, background: "transparent", color: t.t }} />
                    <button onClick={submitCalibration} className="btn-g" style={{ padding: "0 14px", borderRadius: 6, fontSize: 13, fontWeight: 600 }}>Calibrate</button>
                  </div>
                </div>
              )}
            </div>
          )}
        </div>
      )}

      {/* Manual form */}
      {showForm && (
        <div className={`asc ${t.gl}`} style={{ borderRadius: 16, padding: "20px", marginBottom: 20 }}>
          <h3 className="fs" style={{ fontSize: 16, fontWeight: 700, color: t.t, marginBottom: 16 }}>Log a Meal</h3>
          <div style={{ display: "grid", gridTemplateColumns: "2fr 1fr 1fr 1fr 1fr 1fr", gap: 10, marginBottom: 12 }}>
            {fi("name", "Meal name")}{fi("cal", "Calories")}{fi("protein", "Protein (g)")}
            {fi("carbs", "Carbs (g)")}{fi("fat", "Fat (g)")}{fi("time", "Time")}
          </div>
          <div style={{ display: "flex", justifyContent: "flex-end" }}>
            <button onClick={() => doAdd(newMeal)} disabled={saving} className="btn-g"
              style={{ padding: "10px 24px", borderRadius: 8, fontSize: 14, display: "flex", alignItems: "center", gap: 8, opacity: saving ? .7 : 1 }}>
              Add Meal
            </button>
          </div>
        </div>
      )}

      {/* Meal list */}
      <div style={{ display: "flex", flexDirection: "column", gap: 10 }}>
        <h3 className="fs" style={{ fontSize: 16, fontWeight: 700, color: t.t, marginBottom: 4 }}>Today's Meals</h3>
        {meals.map((m, i) => (
          <div key={m.id} className={`${t.gl} hvup asr`}
            style={{ borderRadius: 14, padding: "16px 18px", display: "flex", alignItems: "center", gap: 16, animationDelay: `${i * 0.06}s` }}>
            <div style={{ fontSize: 28 }}>{m.emoji}</div>
            <div style={{ flex: 1 }}>
              <div style={{ fontWeight: 600, color: t.t, fontSize: 15, marginBottom: 2 }}>{m.name}</div>
              <div style={{ fontSize: 12, color: t.t3, display: "flex", gap: 12 }}>
                <span><Clock size={11} style={{ marginRight: 3 }} />{m.time}</span>
                <span style={{ color: "#10b981" }}>P: {m.protein}g</span>
                <span style={{ color: "#f59e0b" }}>C: {m.carbs}g</span>
                <span style={{ color: "#a855f7" }}>F: {m.fat}g</span>
              </div>
            </div>
            <div style={{ textAlign: "right" }}>
              <div className="fs" style={{ fontSize: 20, fontWeight: 700, color: "#10b981" }}>{m.cal}</div>
              <div style={{ fontSize: 11, color: t.t3 }}>kcal</div>
            </div>
            <button onClick={() => doDelete(m.id)} className="btn-o"
              style={{ padding: 6, border: "none", borderRadius: 8, color: "#ef4444", opacity: .6 }}>
              <Trash2 size={15} />
            </button>
          </div>
        ))}
        {meals.length === 0 && (
          <div style={{ textAlign: "center", padding: 40, color: t.t3 }}>No meals logged yet. Add your first meal above!</div>
        )}
      </div>
    </div>
  );
}



/* ══════════════════════════════════════════════
   AI CHAT — wired to /coach/sessions + /coach/chat
══════════════════════════════════════════════ */
function AIChat({ darkMode }) {
  const t = darkMode ? T.d : T.l;

  const WELCOME = { role: "assistant", content: "👋 Hey! I'm **Byte**, your AI nutrition coach. Ask me anything about calories, meal plans, macros, or healthy eating!" };

  const [sessions, setSessions] = useState([]);
  const [activeId, setActiveId] = useState(null);
  const [msgs, setMsgs] = useState([WELCOME]);
  const [input, setInput] = useState("");
  const [typing, setTyping] = useState(false);
  const [loadingSess, setLoadingSess] = useState(true);
  const [loadingHist, setLoadingHist] = useState(false);
  const bottomRef = useRef(null);
  const taRef = useRef(null);

  useEffect(() => { bottomRef.current?.scrollIntoView({ behavior: "smooth" }); }, [msgs, typing]);

  useEffect(() => {
    if (taRef.current) {
      taRef.current.style.height = "auto";
      taRef.current.style.height = Math.min(taRef.current.scrollHeight, 120) + "px";
    }
  }, [input]);

  /* Load sessions on mount */
  useEffect(() => {
    (async () => {
      try {
        const data = await CoachAPI.getSessions();
        const list = extractArray(data, ["sessions", "chats", "chatSessions"]);
        setSessions(list);
      } catch {
        setSessions([]);
      } finally {
        setLoadingSess(false);
      }
    })();
  }, []);

  /* Load history when session selected */
  const openSession = async (sid) => {
    if (sid === activeId) return;
    setActiveId(sid);
    setLoadingHist(true);
    setMsgs([]);
    try {
      const data = await CoachAPI.getHistory(sid);
      const raw = extractArray(data, ["messages", "history", "chatHistory"]);
      setMsgs(raw.length ? raw.map(normalizeMsg) : [WELCOME]);
    } catch {
      setMsgs([WELCOME]);
    } finally {
      setLoadingHist(false);
    }
  };

  /* New session */
  const newSession = () => {
    setActiveId(null);
    setMsgs([WELCOME]);
  };

  /* Delete session */
  const deleteSession = async (e, sid) => {
    e.stopPropagation();
    setSessions(p => p.filter(s => (s.id || s._id) !== sid));
    if (activeId === sid) newSession();
    try { await CoachAPI.deleteSession(sid); } catch (err) { console.error(err); }
  };

  /* Send message */
  const send = async (text = input.trim()) => {
    if (!text || typing) return;
    setInput("");
    const userMsg = { role: "user", content: text };
    setMsgs(p => [...p, userMsg]);
    setTyping(true);
    try {
      const data = await CoachAPI.send(activeId, text);
      const inner = data?.data || {};
      const payload = inner?.data || {};

      const replyText = payload.coach_response || inner.coach_response || data?.coach_response ||
                        payload.reply || inner.reply || data?.reply ||
                        payload.content || inner.content || data?.content ||
                        payload.response || inner.response || data?.response ||
                        payload.message || inner.message || data?.message || "…";

      const newSid = payload.session_id || inner.session_id || data?.session_id ||
                     payload.sessionId || inner.sessionId || data?.sessionId ||
                     payload.chatId || inner.chatId || data?.chatId || activeId;

      const assistantMsg = { role: "assistant", content: replyText };
      setMsgs(p => [...p, assistantMsg]);

      /* If a new session was created, add it to the list */
      if (newSid && newSid !== activeId) {
        setActiveId(newSid);
        const newSess = payload.session || inner.session || data?.session || { id: newSid, title: text.slice(0, 30) };
        setSessions(p => [newSess, ...p]);
      }
    } catch (err) {
      console.error(err);
      setMsgs(p => [...p, { role: "assistant", content: "Sorry, I ran into an issue. Please try again." }]);
    } finally {
      setTyping(false);
    }
  };

  const renderMsg = (content) =>
    String(content).split("\n").map((line, i, arr) => {
      const html = line.replace(/\*\*(.*?)\*\*/g, "<strong>$1</strong>");
      return <span key={i} dangerouslySetInnerHTML={{ __html: html + (i < arr.length - 1 ? "<br/>" : "") }} />;
    });

  return (
    <div style={{ flex: 1, display: "flex", height: "100vh", background: t.bg, overflow: "hidden" }}>

      {/* Sessions sidebar */}
      <div style={{ width: 220, borderRight: `1px solid ${t.bdr}`, display: "flex", flexDirection: "column", padding: "16px 10px", background: t.bg2, flexShrink: 0 }}>
        <div style={{ display: "flex", alignItems: "center", gap: 8, marginBottom: 14, padding: "0 4px" }}>
          <Bot size={16} color="#10b981" />
          <span style={{ fontSize: 13, fontWeight: 600, color: t.t }}>Byte AI</span>
        </div>

        <button onClick={newSession} className="btn-g"
          style={{ padding: "8px 12px", borderRadius: 8, fontSize: 12, marginBottom: 14, display: "flex", alignItems: "center", gap: 6 }}>
          <Plus size={13} />New Chat
        </button>

        <div style={{ fontSize: 11, color: t.t3, marginBottom: 8, padding: "0 4px", letterSpacing: .5 }}>SESSIONS</div>

        <div style={{ flex: 1, overflowY: "auto", display: "flex", flexDirection: "column", gap: 2 }}>
          {loadingSess ? (
            <div style={{ textAlign: "center", padding: 20 }}>
              <div style={{ width: 18, height: 18, border: "2px solid rgba(16,185,129,.3)", borderTopColor: "#10b981", borderRadius: "50%", animation: "spin .7s linear infinite", margin: "0 auto" }} />
            </div>
          ) : sessions.length === 0 ? (
            <p style={{ fontSize: 12, color: t.t3, textAlign: "center", marginTop: 12 }}>No sessions yet</p>
          ) : (
            sessions.map(s => {
              const sid = s.id || s._id || s.chatId;
              const title = s.title || s.name || s.firstMessage || `Session ${sid?.slice(-4) || ""}`;
              const isAct = sid === activeId;
              return (
                <div key={sid} onClick={() => openSession(sid)}
                  style={{
                    padding: "8px 10px", borderRadius: 8, fontSize: 12, color: isAct ? t.acc : t.t2, cursor: "pointer",
                    background: isAct ? (darkMode ? "rgba(16,185,129,.12)" : "rgba(16,185,129,.08)") : "transparent",
                    display: "flex", alignItems: "center", justifyContent: "space-between", gap: 6, transition: "all .15s"
                  }}
                  onMouseEnter={e => { if (!isAct) e.currentTarget.style.background = darkMode ? "rgba(255,255,255,.05)" : "rgba(0,0,0,.04)"; }}
                  onMouseLeave={e => { if (!isAct) e.currentTarget.style.background = "transparent"; }}>
                  <span style={{ overflow: "hidden", textOverflow: "ellipsis", whiteSpace: "nowrap" }}>💬 {title}</span>
                  <button onClick={e => deleteSession(e, sid)} className="btn-o"
                    style={{ padding: 2, border: "none", color: "#ef4444", opacity: .5, flexShrink: 0 }}
                    onMouseEnter={e => e.currentTarget.style.opacity = "1"}
                    onMouseLeave={e => e.currentTarget.style.opacity = ".5"}>
                    <X size={11} />
                  </button>
                </div>
              );
            })
          )}
        </div>

        <div style={{ marginTop: "auto", padding: "12px 4px 0", borderTop: `1px solid ${t.bdr}` }}>
          <div style={{ fontSize: 11, color: t.t3, lineHeight: 1.5 }}>Powered by<br /><span style={{ color: "#10b981" }}>BiteSmart AI</span></div>
        </div>
      </div>

      {/* Chat area */}
      <div style={{ flex: 1, display: "flex", flexDirection: "column", minWidth: 0 }}>
        {/* Header */}
        <div style={{ borderBottom: `1px solid ${t.bdr}`, padding: "14px 24px", display: "flex", alignItems: "center", gap: 10 }}>
          <div style={{ width: 34, height: 34, borderRadius: "50%", background: "linear-gradient(135deg,#10b981,#059669)", display: "flex", alignItems: "center", justifyContent: "center" }}>
            <Bot size={18} color="white" />
          </div>
          <div>
            <div style={{ fontWeight: 600, color: t.t, fontSize: 15 }}>Byte — Nutrition AI</div>
            <div style={{ fontSize: 12, color: "#10b981", display: "flex", alignItems: "center", gap: 4 }}>
              <div style={{ width: 7, height: 7, borderRadius: "50%", background: "#10b981" }} />
              {typing ? "Thinking…" : "Online"}
            </div>
          </div>
        </div>

        {/* Messages */}
        <div style={{ flex: 1, overflowY: "auto", padding: "24px", display: "flex", flexDirection: "column", gap: 16, position: "relative" }}>
          {loadingHist ? (
            <div style={{ textAlign: "center", paddingTop: 60, color: t.t3 }}>
              <div style={{ width: 24, height: 24, border: "2px solid rgba(16,185,129,.3)", borderTopColor: "#10b981", borderRadius: "50%", animation: "spin .7s linear infinite", margin: "0 auto 12px" }} />
              Loading history…
            </div>
          ) : (
            msgs.map((m, i) => (
              <div key={i} className="afi"
                style={{ display: "flex", justifyContent: m.role === "user" ? "flex-end" : "flex-start", gap: 10, alignItems: "flex-end" }}>
                {m.role === "assistant" && (
                  <div style={{ width: 30, height: 30, borderRadius: "50%", background: "linear-gradient(135deg,#10b981,#059669)", display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0 }}>
                    <Bot size={14} color="white" />
                  </div>
                )}
                <div className={m.role === "user" ? "bubble-u" : "bubble-a"}
                  style={{
                    maxWidth: "72%", padding: "12px 16px", fontSize: 14, lineHeight: 1.75,
                    background: m.role === "assistant" ? (darkMode ? "rgba(255,255,255,.06)" : "rgba(0,0,0,.05)") : "",
                    color: m.role === "user" ? "white" : t.t
                  }}>
                  {renderMsg(m.content)}
                </div>
                {m.role === "user" && (
                  <div style={{ width: 30, height: 30, borderRadius: "50%", background: "linear-gradient(135deg,#6366f1,#8b5cf6)", display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0, fontSize: 13, fontWeight: 700, color: "white" }}>
                    U
                  </div>
                )}
              </div>
            ))
          )}

          {typing && (
            <div className="afi" style={{ display: "flex", gap: 10, alignItems: "flex-end" }}>
              <div style={{ width: 30, height: 30, borderRadius: "50%", background: "linear-gradient(135deg,#10b981,#059669)", display: "flex", alignItems: "center", justifyContent: "center" }}>
                <Bot size={14} color="white" />
              </div>
              <div className="bubble-a" style={{ padding: "14px 18px", background: darkMode ? "rgba(255,255,255,.06)" : "rgba(0,0,0,.05)" }}>
                <div style={{ display: "flex", gap: 5, alignItems: "center" }}>
                  <div className="sb dot1" /><div className="sb dot2" /><div className="sb dot3" />
                </div>
              </div>
            </div>
          )}
          <div ref={bottomRef} />
        </div>

        {/* Quick suggestions */}
        {msgs.length <= 1 && !loadingHist && (
          <div style={{ padding: "0 24px 12px", display: "flex", gap: 8, flexWrap: "wrap" }}>
            {quickSugg.map((s, i) => (
              <button key={i} onClick={() => send(s)} className="btn-o"
                style={{ padding: "7px 14px", borderRadius: 20, fontSize: 12, border: `1px solid ${t.bdr}`, color: t.t2, cursor: "pointer", background: "transparent", fontFamily: "'DM Sans',sans-serif", transition: "all .15s" }}
                onMouseEnter={e => { e.currentTarget.style.borderColor = t.acc; e.currentTarget.style.color = t.acc; }}
                onMouseLeave={e => { e.currentTarget.style.borderColor = t.bdr; e.currentTarget.style.color = t.t2; }}>
                {s}
              </button>
            ))}
          </div>
        )}

        {/* Input */}
        <div style={{ padding: "12px 20px 20px", borderTop: `1px solid ${t.bdr}` }}>
          <div style={{ display: "flex", gap: 10, alignItems: "flex-end", background: darkMode ? "rgba(255,255,255,.05)" : "rgba(0,0,0,.04)", borderRadius: 16, border: `1px solid ${t.bdr}`, padding: "8px 8px 8px 16px" }}>
            <textarea ref={taRef} value={input}
              onChange={e => setInput(e.target.value)}
              onKeyDown={e => { if (e.key === "Enter" && !e.shiftKey) { e.preventDefault(); send(); } }}
              placeholder="Ask Byte anything about nutrition…"
              rows={1}
              style={{ flex: 1, background: "transparent", border: "none", resize: "none", fontSize: 14, color: t.t, fontFamily: "'DM Sans',sans-serif", lineHeight: 1.5, maxHeight: 120, outline: "none", padding: "4px 0", overflowY: "auto" }} />
            <button onClick={() => send()} disabled={!input.trim() || typing} className="btn-g"
              style={{ width: 38, height: 38, borderRadius: 10, display: "flex", alignItems: "center", justifyContent: "center", flexShrink: 0, opacity: (!input.trim() || typing) ? .4 : 1 }}>
              {typing ? <Spinner size={16} /> : <Send size={16} />}
            </button>
          </div>
          <p style={{ fontSize: 11, color: t.t3, textAlign: "center", margin: "8px 0 0" }}>
            Byte can make mistakes. Verify important health info with a professional.
          </p>
        </div>
      </div>
    </div>
  );
}

/* ══════════════════════════════════════════════
   APP LAYOUT
══════════════════════════════════════════════ */
function AppLayout({ page, setPage, setAuthed, darkMode, setDarkMode, addToast, currentUser }) {
  const t = darkMode ? T.d : T.l;
  return (
    <div style={{ display: "flex", minHeight: "100vh", background: t.bg }}>
      <Sidebar page={page} setPage={setPage} setAuthed={setAuthed} darkMode={darkMode} setDarkMode={setDarkMode} />
      <div style={{ flex: 1, display: "flex", flexDirection: "column", minWidth: 0 }}>
        {page === "dashboard" && <Dashboard darkMode={darkMode} currentUser={currentUser} />}
        
        {/* Updated Tracker Line Here */}
        {page === "tracker" && (
          <CalorieTracker 
            darkMode={darkMode} 
            addToast={addToast} 
            MealsAPI={MealsAPI} 
            PredictionAPI={PredictionAPI} 
            extractArray={extractArray} 
            normalizeMeal={normalizeMeal} 
            T={T} 
          />
        )}
        
        {page === "bmi" && <BMICalculator darkMode={darkMode} />}
        {page === "chat" && <AIChat darkMode={darkMode} />}
      </div>
    </div>
  );
}

/* ══════════════════════════════════════════════
   ROOT
══════════════════════════════════════════════ */
export default function App() {
  const [page, setPage] = useState(() => Token.get() ? "dashboard" : "landing");
  const [authed, setAuthed] = useState(() => !!Token.get());
  const [currentUser, setCurrentUser] = useState(null);
  const [dark, setDark] = useState(true);
  const [toasts, setToasts] = useState([]);

  useEffect(() => {
    const el = document.createElement("style");
    el.textContent = CSS;
    document.head.appendChild(el);
    return () => document.head.removeChild(el);
  }, []);

  const addToast = (msg, type = "success") => {
    const id = Date.now();
    setToasts(p => [...p, { id, msg, type }]);
    setTimeout(() => setToasts(p => p.filter(x => x.id !== id)), 3000);
  };

  const t = dark ? T.d : T.l;
  const appPages = ["dashboard", "tracker", "bmi", "chat"];

  return (
    <div style={{ minHeight: "100vh", background: t.bg, color: t.t, transition: "background .3s,color .3s" }}>
      {!authed && !["signin", "signup"].includes(page) && (
        <Navbar setPage={setPage} darkMode={dark} setDarkMode={setDark} />
      )}
      {page === "landing" && !authed && <LandingPage setPage={setPage} darkMode={dark} />}
      {(page === "signin" || page === "signup") && (
        <AuthPage setPage={setPage} setAuthed={setAuthed} setCurrentUser={setCurrentUser}
          darkMode={dark} isSignup={page === "signup"} setDarkMode={setDark} />
      )}
      {authed && appPages.includes(page) && (
        <AppLayout page={page} setPage={setPage}
          setAuthed={v => { setAuthed(v); if (!v) setPage("landing"); }}
          darkMode={dark} setDarkMode={setDark} addToast={addToast} currentUser={currentUser} />
      )}
      <Toast toasts={toasts} dark={dark} />
    </div>
  );
}
