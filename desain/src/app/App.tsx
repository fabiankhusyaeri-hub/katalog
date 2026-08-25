import { useState, useEffect } from "react";
import {
  Home, Search, ShoppingBag, User, Bell, ChevronRight,
  ChevronLeft, ChevronDown, Package, BarChart2, Users,
  Scan, Plus, TrendingUp, AlertTriangle, Download, Filter,
  Edit, Trash2, MessageSquare, QrCode, X, Check,
  ShoppingCart, Layers, LogOut, CheckCircle, Settings,
  Tag, Wallet, Clock, FileText, RefreshCw, Zap, Globe,
  Grid2X2, Send
} from "lucide-react";
import {
  BarChart as ReBarChart, Bar, XAxis, YAxis, Tooltip,
  ResponsiveContainer, CartesianGrid,
} from "recharts";

// ── Types ────────────────────────────────────────────────────────────────────
type Screen =
  | "welcome" | "login"
  | "siswa-home" | "siswa-katalog" | "siswa-pesanan" | "siswa-profil"
  | "siswa-checkout" | "siswa-qris"
  | "admin-dashboard" | "admin-scanner" | "admin-add-user" | "admin-products"
  | "hubin-dashboard" | "hubin-admins" | "hubin-reports";

type Role = "siswa" | "admin" | "hubin";

// ── Mock Data ─────────────────────────────────────────────────────────────────
const PRODUCTS = [
  { id: 1, name: "Arduino Uno R3", price: 85000, category: "Elektronika", stock: 12, img: "photo-1553406830-ef2513450d76", badge: "Tersedia" },
  { id: 2, name: "Breadboard 830 Titik", price: 25000, category: "Elektronika", stock: 3, img: "photo-1518770660439-4636190af475", badge: "Stok Terbatas" },
  { id: 3, name: "Kabel UTP Cat6 (1m)", price: 15000, category: "TKJ", stock: 45, img: "photo-1558618666-fcd25c85cd64", badge: "Tersedia" },
  { id: 4, name: "Flash Drive 32GB", price: 45000, category: "TKJ", stock: 0, img: "photo-1601784551446-20c9e07cdbdb", badge: "Habis" },
  { id: 5, name: "Modul LCD 16x2", price: 35000, category: "Elektronika", stock: 8, img: "photo-1518770660439-4636190af475", badge: "Tersedia" },
  { id: 6, name: "Resistor Set 100pcs", price: 20000, category: "Elektronika", stock: 20, img: "photo-1518770660439-4636190af475", badge: "Tersedia" },
];

const CATEGORIES = ["Semua", "Elektronika", "TKJ", "RPL", "Tata Boga"];

const SALES_DAILY = [
  { day: "Sen", value: 125000 },
  { day: "Sel", value: 210000 },
  { day: "Rab", value: 85000 },
  { day: "Kam", value: 310000 },
  { day: "Jum", value: 195000 },
  { day: "Sab", value: 165000 },
  { day: "Min", value: 90000 },
];

const SALES_MONTHLY = [
  { month: "Mar", value: 3200000 },
  { month: "Apr", value: 4100000 },
  { month: "Mei", value: 3700000 },
  { month: "Jun", value: 5200000 },
  { month: "Jul", value: 4800000 },
  { month: "Agt", value: 2100000 },
];

const ADMINS_DATA = [
  { id: 1, name: "Budi Santoso, S.T.", dept: "Teknik Elektronika", lastActive: "2 jam lalu", initials: "BS", color: "#1B5BFF" },
  { id: 2, name: "Sari Dewi, S.Kom.", dept: "Teknik Komputer & Jaringan", lastActive: "1 hari lalu", initials: "SD", color: "#8B5CF6" },
  { id: 3, name: "Hendra Wijaya, S.T.", dept: "Rekayasa Perangkat Lunak", lastActive: "3 jam lalu", initials: "HW", color: "#F59E0B" },
  { id: 4, name: "Rina Kusuma, S.Pd.", dept: "Tata Boga", lastActive: "5 jam lalu", initials: "RK", color: "#22D07A" },
];

const WA_LOGS = [
  { id: 1, user: "Andi Pratama", msg: "Pendaftaran berhasil dikirim", time: "08:32", status: "delivered" },
  { id: 2, user: "Dewi Sartika", msg: "Pesanan ORD-002 dikonfirmasi", time: "09:15", status: "sent" },
  { id: 3, user: "Budi Hartono", msg: "Stok Breadboard menipis (3 unit)", time: "10:04", status: "delivered" },
  { id: 4, user: "Rizky Aditya", msg: "Pembayaran Rp 85K diterima", time: "11:22", status: "delivered" },
];

const ORDERS = [
  { id: "ORD-001", product: "Arduino Uno R3", qty: 1, total: 85000, status: "Dikonfirmasi", date: "22 Agt 2026" },
  { id: "ORD-002", product: "Breadboard 830T", qty: 2, total: 50000, status: "Menunggu", date: "22 Agt 2026" },
  { id: "ORD-003", product: "Resistor Set", qty: 3, total: 60000, status: "Selesai", date: "21 Agt 2026" },
];

const DEPARTMENTS = [
  { name: "Teknik Elektronika", products: 48, todaySales: 215000, color: "#1B5BFF" },
  { name: "TKJ", products: 32, todaySales: 145000, color: "#8B5CF6" },
  { name: "RPL", products: 27, todaySales: 98000, color: "#F59E0B" },
  { name: "Tata Boga", products: 61, todaySales: 320000, color: "#22D07A" },
];

const TRANSACTIONS = [
  { id: "TRX-001", dept: "Teknik Elektronika", product: "Arduino Uno R3", amount: 85000, time: "10:32" },
  { id: "TRX-002", dept: "TKJ", product: "Kabel UTP Cat6 (3m)", amount: 45000, time: "10:15" },
  { id: "TRX-003", dept: "Tata Boga", product: "Snack Box Premium", amount: 45000, time: "09:58" },
  { id: "TRX-004", dept: "RPL", product: "Modul PHP Dasar", amount: 25000, time: "09:33" },
  { id: "TRX-005", dept: "Teknik Elektronika", product: "Resistor Set", amount: 60000, time: "09:12" },
];

// ── Utility Components ───────────────────────────────────────────────────────

function StatusBar({ light = false }: { light?: boolean }) {
  const tc = light ? "text-white" : "text-foreground";
  return (
    <div className={`flex items-center justify-between px-6 pt-[52px] pb-2 ${tc} pointer-events-none`}>
      <span className="text-[13px] font-[800]">09:41</span>
      <div className="flex items-center gap-1.5">
        <svg width="16" height="11" viewBox="0 0 16 11" fill="currentColor">
          <rect x="0" y="7" width="3" height="4" rx="0.5" opacity="0.4"/>
          <rect x="4.5" y="4.5" width="3" height="6.5" rx="0.5" opacity="0.65"/>
          <rect x="9" y="2" width="3" height="9" rx="0.5" opacity="0.85"/>
          <rect x="13.5" y="0" width="2.5" height="11" rx="0.5"/>
        </svg>
        <svg width="14" height="10" viewBox="0 0 24 18" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round">
          <path d="M5 9a10 10 0 0 1 14 0"/>
          <path d="M1.5 5.5a16 16 0 0 1 21 0"/>
          <path d="M8.5 12.5a5 5 0 0 1 7 0"/>
          <circle cx="12" cy="16" r="1.5" fill="currentColor"/>
        </svg>
        <div className="flex items-center">
          <div className="w-[22px] h-[11px] rounded-[3px] border-[1.5px] border-current relative">
            <div className="absolute inset-[2px] right-[5px] rounded-[1px] bg-current"/>
            <div className="absolute right-[-4px] top-1/2 -translate-y-1/2 w-[3px] h-[5px] bg-current rounded-r-sm opacity-50"/>
          </div>
        </div>
      </div>
    </div>
  );
}

function TopBar({
  title, onBack, rightEl, light = false,
}: {
  title?: string;
  onBack?: () => void;
  rightEl?: React.ReactNode;
  light?: boolean;
}) {
  const tc = light ? "text-white border-white/20" : "text-foreground border-border bg-card";
  return (
    <div className="flex items-center justify-between px-5 py-2">
      {onBack ? (
        <button onClick={onBack} className={`w-9 h-9 rounded-full border flex items-center justify-center ${tc}`}>
          <ChevronLeft className="w-5 h-5" />
        </button>
      ) : <div className="w-9" />}
      {title && <span className={`font-[700] text-[15px] ${light ? "text-white" : "text-foreground"}`}>{title}</span>}
      {rightEl ?? <div className="w-9" />}
    </div>
  );
}

function SiswaNav({ active, go }: { active: Screen; go: (s: Screen) => void }) {
  const items: { s: Screen; Icon: React.ElementType; label: string }[] = [
    { s: "siswa-home", Icon: Home, label: "Beranda" },
    { s: "siswa-katalog", Icon: Grid2X2, label: "Katalog" },
    { s: "siswa-pesanan", Icon: ShoppingBag, label: "Pesanan" },
    { s: "siswa-profil", Icon: User, label: "Profil" },
  ];
  return (
    <div className="absolute bottom-0 left-0 right-0 bg-card border-t border-border pb-6 pt-2 z-30">
      <div className="flex">
        {items.map(({ s, Icon, label }) => (
          <button key={s} onClick={() => go(s)}
            className={`flex-1 flex flex-col items-center gap-1 py-1 transition-colors ${active === s ? "text-primary" : "text-muted-foreground"}`}>
            <Icon className="w-[22px] h-[22px]" />
            <span className="text-[10px] font-[700]">{label}</span>
          </button>
        ))}
      </div>
    </div>
  );
}

function AdminNav({ active, go }: { active: Screen; go: (s: Screen) => void }) {
  const items: { s: Screen; Icon: React.ElementType; label: string }[] = [
    { s: "admin-dashboard", Icon: BarChart2, label: "Dashboard" },
    { s: "admin-products", Icon: Package, label: "Produk" },
    { s: "admin-scanner", Icon: Scan, label: "Scanner" },
    { s: "admin-add-user", Icon: Users, label: "Pengguna" },
  ];
  return (
    <div className="absolute bottom-0 left-0 right-0 bg-card border-t border-border pb-6 pt-2 z-30">
      <div className="flex">
        {items.map(({ s, Icon, label }) => (
          <button key={s} onClick={() => go(s)}
            className={`flex-1 flex flex-col items-center gap-1 py-1 transition-colors ${active === s ? "text-primary" : "text-muted-foreground"}`}>
            <Icon className="w-[22px] h-[22px]" />
            <span className="text-[10px] font-[700]">{label}</span>
          </button>
        ))}
      </div>
    </div>
  );
}

function HubinNav({ active, go }: { active: Screen; go: (s: Screen) => void }) {
  const items: { s: Screen; Icon: React.ElementType; label: string }[] = [
    { s: "hubin-dashboard", Icon: TrendingUp, label: "Overview" },
    { s: "hubin-admins", Icon: Users, label: "Kelola Admin" },
    { s: "hubin-reports", Icon: FileText, label: "Laporan" },
  ];
  return (
    <div className="absolute bottom-0 left-0 right-0 bg-card border-t border-border pb-6 pt-2 z-30">
      <div className="flex">
        {items.map(({ s, Icon, label }) => (
          <button key={s} onClick={() => go(s)}
            className={`flex-1 flex flex-col items-center gap-1 py-1 transition-colors ${active === s ? "text-[#7C3AED]" : "text-muted-foreground"}`}>
            <Icon className="w-[22px] h-[22px]" />
            <span className="text-[10px] font-[700]">{label}</span>
          </button>
        ))}
      </div>
    </div>
  );
}

// ── Screen: Welcome ───────────────────────────────────────────────────────────
function WelcomeScreen({ go }: { go: (s: Screen) => void }) {
  return (
    <div className="relative h-full flex flex-col overflow-hidden">
      <div className="absolute inset-0 bg-gradient-to-br from-[#1B5BFF] via-[#1040CC] to-[#07195C]" />
      <div className="absolute inset-0 opacity-[0.07]"
        style={{ backgroundImage: "radial-gradient(circle, white 1px, transparent 1px)", backgroundSize: "32px 32px" }} />
      <div className="absolute bottom-0 left-0 w-72 h-72 bg-white/5 rounded-full -translate-x-1/3 translate-y-1/3" />
      <div className="absolute top-1/3 right-0 w-40 h-40 bg-white/5 rounded-full translate-x-1/2" />

      <div className="relative z-10 flex-1 flex flex-col items-center pt-20 px-6">
        <div className="w-20 h-20 bg-white rounded-[20px] flex items-center justify-center shadow-2xl mb-4">
          <div className="w-13 h-13 bg-primary rounded-[14px] flex items-center justify-center">
            <Layers className="w-8 h-8 text-white" />
          </div>
        </div>

        <h1 className="text-white text-[24px] font-[800] text-center">SMK Nusantara 1</h1>
        <p className="text-white/60 text-sm mt-0.5 font-[600]">Yogyakarta</p>

        <div className="w-full mt-5 rounded-[20px] overflow-hidden h-36 bg-white/10">
          <img
            src="https://images.unsplash.com/photo-1580582932707-520aed937b7b?w=640&h=288&fit=crop&auto=format"
            alt="Gedung SMK Nusantara 1"
            className="w-full h-full object-cover opacity-75"
          />
        </div>

        <div className="w-full mt-5 bg-white/10 backdrop-blur-sm rounded-[20px] p-5 border border-white/15">
          <p className="text-white/85 text-[13px] leading-relaxed text-center italic">
            &ldquo;Mencetak generasi terampil, berkarakter, dan siap kerja di era industri 4.0&rdquo;
          </p>
          <div className="flex justify-center gap-6 mt-4">
            {[["6", "Jurusan"], ["234", "Produk"], ["1.2K+", "Siswa"]].map(([v, l]) => (
              <div key={l} className="text-center">
                <p className="text-white text-lg font-[800]">{v}</p>
                <p className="text-white/50 text-[10px] font-[600]">{l}</p>
              </div>
            ))}
          </div>
        </div>
      </div>

      <div className="relative z-10 px-6 pb-10 pt-4">
        <button
          onClick={() => go("login")}
          className="w-full py-4 bg-white rounded-[18px] font-[800] text-primary text-[16px] shadow-2xl active:scale-[0.98] transition-transform"
        >
          Masuk ke Aplikasi
        </button>
        <p className="text-white/35 text-center text-[11px] mt-3 font-[600]">
          Marketplace &amp; Inventori Jurusan SMK
        </p>
      </div>
    </div>
  );
}

// ── Screen: Login ─────────────────────────────────────────────────────────────
function LoginScreen({ go, back }: { go: (s: Screen) => void; back: () => void }) {
  const [role, setRole] = useState<Role>("siswa");
  const [nis, setNis] = useState("");
  const [pass, setPass] = useState("");
  const dest: Record<Role, Screen> = { siswa: "siswa-home", admin: "admin-dashboard", hubin: "hubin-dashboard" };

  const tabs: { key: Role; label: string }[] = [
    { key: "siswa", label: "Siswa" },
    { key: "admin", label: "Ketua Jurusan" },
    { key: "hubin", label: "Hubin" },
  ];

  const roleInfo: Record<Role, { icon: React.ElementType; desc: string }> = {
    siswa: { icon: User, desc: "Akses katalog produk & buat pesanan" },
    admin: { icon: Package, desc: "Kelola produk & stok inventori jurusan" },
    hubin: { icon: Globe, desc: "Pantau semua jurusan & ekspor laporan" },
  };

  const { icon: RoleIcon, desc } = roleInfo[role];

  return (
    <div className="h-full flex flex-col bg-background overflow-y-auto">
      <div className="bg-primary px-6 pt-0 pb-8 relative overflow-hidden flex-shrink-0">
        <div className="absolute top-0 right-0 w-40 h-40 bg-white/10 rounded-full -translate-y-1/2 translate-x-1/3" />
        <StatusBar light />
        <button onClick={back} className="relative z-10 w-8 h-8 rounded-full bg-white/20 flex items-center justify-center mb-3">
          <ChevronLeft className="w-4 h-4 text-white" />
        </button>
        <h1 className="text-white text-[22px] font-[800] relative z-10">Selamat Datang!</h1>
        <p className="text-white/65 text-sm mt-0.5 relative z-10 font-[600]">Masuk ke akun kamu</p>
      </div>

      <div className="-mt-4 bg-background rounded-t-[28px] px-5 pt-5 pb-6 flex-1">
        <div className="bg-muted rounded-[18px] p-1 flex mb-5">
          {tabs.map(({ key, label }) => (
            <button
              key={key}
              onClick={() => setRole(key)}
              className={`flex-1 py-2.5 rounded-[14px] text-[11.5px] font-[800] transition-all ${
                role === key ? "bg-primary text-white shadow-md" : "text-muted-foreground"
              }`}
            >
              {label}
            </button>
          ))}
        </div>

        <div className="space-y-3.5">
          <div>
            <label className="text-[12px] font-[700] text-muted-foreground mb-1.5 block">
              {role === "siswa" ? "NIS (Nomor Induk Siswa)" : "NIK / ID Karyawan"}
            </label>
            <div className="relative">
              <User className="absolute left-4 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground" />
              <input
                type="text"
                placeholder={role === "siswa" ? "Masukkan NIS kamu" : "Masukkan NIK kamu"}
                value={nis}
                onChange={e => setNis(e.target.value)}
                className="w-full pl-11 pr-4 py-3.5 bg-card border border-border rounded-[14px] text-sm text-foreground placeholder-muted-foreground focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary/30"
              />
            </div>
          </div>

          <div>
            <label className="text-[12px] font-[700] text-muted-foreground mb-1.5 block">Kata Sandi</label>
            <div className="relative">
              <Settings className="absolute left-4 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground" />
              <input
                type="password"
                placeholder="Masukkan kata sandi"
                value={pass}
                onChange={e => setPass(e.target.value)}
                className="w-full pl-11 pr-4 py-3.5 bg-card border border-border rounded-[14px] text-sm text-foreground placeholder-muted-foreground focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary/30"
              />
            </div>
          </div>

          <div className="text-right -mt-1">
            <button className="text-primary text-[12px] font-[700]">Lupa kata sandi?</button>
          </div>

          <button
            onClick={() => go(dest[role])}
            className="w-full py-3.5 bg-primary rounded-[16px] font-[800] text-white text-[15px] shadow-lg shadow-primary/25 mt-1"
          >
            Masuk
          </button>
        </div>

        <div className="mt-5 p-4 bg-secondary rounded-[16px] border border-primary/10 flex items-start gap-3">
          <div className="w-8 h-8 rounded-[10px] bg-primary/15 flex items-center justify-center flex-shrink-0">
            <RoleIcon className="w-4 h-4 text-primary" />
          </div>
          <div>
            <p className="text-[12px] font-[800] text-primary">
              {role === "siswa" ? "Mode Siswa" : role === "admin" ? "Mode Ketua Jurusan" : "Mode Hubin"}
            </p>
            <p className="text-[11px] text-muted-foreground mt-0.5">{desc}</p>
          </div>
        </div>
      </div>
    </div>
  );
}

// ── Screen: Siswa Home ────────────────────────────────────────────────────────
function SiswaHome({ go }: { go: (s: Screen) => void }) {
  const [cat, setCat] = useState("Semua");
  const [q, setQ] = useState("");

  const badgeCls: Record<string, string> = {
    "Tersedia": "bg-accent/10 text-accent",
    "Stok Terbatas": "bg-amber-100 text-amber-700",
    "Habis": "bg-red-100 text-red-500",
  };

  const filtered = PRODUCTS.filter(p =>
    (cat === "Semua" || p.category === cat) &&
    p.name.toLowerCase().includes(q.toLowerCase())
  );

  return (
    <div className="relative h-full flex flex-col bg-background">
      <div className="flex-shrink-0 px-5 pt-0">
        <StatusBar />
        <div className="flex items-center justify-between mb-3">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-[14px] bg-primary flex items-center justify-center text-white font-[800] text-sm">AP</div>
            <div>
              <p className="text-[11px] text-muted-foreground font-[600]">Selamat datang,</p>
              <p className="text-[15px] font-[800] text-foreground">Andi Pratama</p>
            </div>
          </div>
          <button className="relative w-10 h-10 rounded-full bg-card border border-border flex items-center justify-center shadow-sm">
            <Bell className="w-5 h-5 text-foreground" />
            <span className="absolute top-2 right-2 w-2 h-2 bg-red-500 rounded-full border border-card" />
          </button>
        </div>
        <div className="relative mb-1">
          <Search className="absolute left-3.5 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground" />
          <input
            value={q}
            onChange={e => setQ(e.target.value)}
            placeholder="Cari produk jurusan..."
            className="w-full pl-10 pr-4 py-2.5 bg-card border border-border rounded-[14px] text-[13px] text-foreground placeholder-muted-foreground focus:outline-none focus:border-primary"
          />
        </div>
      </div>

      <div className="flex-1 overflow-y-auto px-5 pb-20">
        {/* Promo banner */}
        <div className="mb-4 mt-3">
          <div className="relative h-32 rounded-[20px] overflow-hidden bg-gradient-to-r from-primary to-[#3B82F6]">
            <img
              src="https://images.unsplash.com/photo-1518770660439-4636190af475?w=800&h=256&fit=crop&auto=format"
              alt="Promo elektronika"
              className="absolute inset-0 w-full h-full object-cover opacity-25"
            />
            <div className="absolute inset-0 p-4 flex flex-col justify-between">
              <div>
                <span className="bg-accent text-white text-[9.5px] font-[800] px-2 py-0.5 rounded-full tracking-wide">PROMO</span>
                <h3 className="text-white font-[800] text-[18px] mt-1 leading-none">Diskon 20%</h3>
                <p className="text-white/75 text-[11px] mt-0.5 font-[600]">Komponen Elektronika s/d 31 Agt</p>
              </div>
              <button onClick={() => go("siswa-katalog")}
                className="self-start bg-white text-primary text-[11px] font-[800] px-3.5 py-1.5 rounded-full shadow">
                Lihat Katalog
              </button>
            </div>
          </div>
          <div className="flex gap-1.5 justify-center mt-2">
            {[0, 1, 2].map(i => (
              <div key={i} className={`h-1.5 rounded-full transition-all ${i === 0 ? "w-5 bg-primary" : "w-1.5 bg-muted"}`} />
            ))}
          </div>
        </div>

        {/* Categories */}
        <div className="flex gap-2 overflow-x-auto pb-2 scrollbar-hide mb-4">
          {CATEGORIES.map(c => (
            <button key={c} onClick={() => setCat(c)}
              className={`flex-shrink-0 px-3.5 py-1.5 rounded-full text-[11.5px] font-[700] transition-all ${
                cat === c ? "bg-primary text-white shadow-md shadow-primary/20" : "bg-card border border-border text-muted-foreground"
              }`}>
              {c}
            </button>
          ))}
        </div>

        {/* Product grid */}
        <div className="flex items-center justify-between mb-3">
          <h2 className="text-[14px] font-[800] text-foreground">
            {cat === "Semua" ? "Semua Produk" : cat}
          </h2>
          <button className="text-primary text-[11.5px] font-[700]">Lihat Semua</button>
        </div>

        <div className="grid grid-cols-2 gap-3">
          {filtered.map(p => (
            <button key={p.id} onClick={() => go("siswa-checkout")}
              className="bg-card rounded-[18px] overflow-hidden border border-border text-left active:scale-[0.97] transition-transform">
              <div className="h-28 bg-muted relative">
                <img
                  src={`https://images.unsplash.com/${p.img}?w=200&h=160&fit=crop&auto=format`}
                  alt={p.name}
                  className="w-full h-full object-cover"
                />
                <span className={`absolute top-2 left-2 text-[9px] font-[800] px-1.5 py-0.5 rounded-full ${badgeCls[p.badge]}`}>
                  {p.badge}
                </span>
              </div>
              <div className="p-2.5">
                <p className="text-[12px] font-[700] text-foreground leading-snug line-clamp-2">{p.name}</p>
                <p className="text-primary text-[13px] font-[800] mt-1">Rp {p.price.toLocaleString("id-ID")}</p>
                <p className="text-muted-foreground text-[10px] mt-0.5">Stok: {p.stock}</p>
              </div>
            </button>
          ))}
        </div>
      </div>

      <SiswaNav active="siswa-home" go={go} />
    </div>
  );
}

// ── Screen: Siswa Katalog ─────────────────────────────────────────────────────
function SiswaKatalog({ go }: { go: (s: Screen) => void }) {
  const [cat, setCat] = useState("Semua");

  const badgeCls: Record<string, string> = {
    "Tersedia": "bg-accent/10 text-accent",
    "Stok Terbatas": "bg-amber-100 text-amber-700",
    "Habis": "bg-red-100 text-red-500",
  };

  return (
    <div className="relative h-full flex flex-col bg-background">
      <div className="flex-shrink-0 px-5 pt-0">
        <StatusBar />
        <h1 className="text-[20px] font-[800] text-foreground mb-3">Katalog Produk</h1>
        <div className="relative mb-2">
          <Search className="absolute left-3.5 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground" />
          <input
            placeholder="Cari produk..."
            className="w-full pl-10 pr-4 py-2.5 bg-card border border-border rounded-[14px] text-[13px] text-foreground placeholder-muted-foreground focus:outline-none focus:border-primary"
          />
        </div>
        <div className="flex gap-2 overflow-x-auto pb-2 scrollbar-hide">
          {CATEGORIES.map(c => (
            <button key={c} onClick={() => setCat(c)}
              className={`flex-shrink-0 px-3.5 py-1.5 rounded-full text-[11.5px] font-[700] ${
                cat === c ? "bg-primary text-white" : "bg-card border border-border text-muted-foreground"
              }`}>
              {c}
            </button>
          ))}
        </div>
      </div>

      <div className="flex-1 overflow-y-auto px-5 pb-20 pt-2">
        <div className="grid grid-cols-2 gap-3">
          {PRODUCTS.filter(p => cat === "Semua" || p.category === cat).map(p => (
            <button key={p.id} onClick={() => go("siswa-checkout")}
              className="bg-card rounded-[18px] overflow-hidden border border-border text-left">
              <div className="h-28 bg-muted relative">
                <img
                  src={`https://images.unsplash.com/${p.img}?w=200&h=160&fit=crop&auto=format`}
                  alt={p.name}
                  className="w-full h-full object-cover"
                />
                <span className={`absolute top-2 left-2 text-[9px] font-[800] px-1.5 py-0.5 rounded-full ${badgeCls[p.badge]}`}>
                  {p.badge}
                </span>
              </div>
              <div className="p-2.5">
                <p className="text-[12px] font-[700] text-foreground leading-snug line-clamp-2">{p.name}</p>
                <p className="text-primary text-[13px] font-[800] mt-1">Rp {p.price.toLocaleString("id-ID")}</p>
                <p className="text-muted-foreground text-[10px] mt-0.5">{p.category}</p>
              </div>
            </button>
          ))}
        </div>
      </div>

      <SiswaNav active="siswa-katalog" go={go} />
    </div>
  );
}

// ── Screen: Siswa Pesanan ─────────────────────────────────────────────────────
function SiswaPesanan({ go }: { go: (s: Screen) => void }) {
  const statusCls: Record<string, string> = {
    "Dikonfirmasi": "bg-primary/10 text-primary",
    "Menunggu": "bg-amber-100 text-amber-700",
    "Selesai": "bg-accent/10 text-accent",
  };

  return (
    <div className="relative h-full flex flex-col bg-background">
      <div className="flex-shrink-0 px-5 pt-0">
        <StatusBar />
        <h1 className="text-[20px] font-[800] text-foreground">Pesanan Saya</h1>
        <p className="text-muted-foreground text-[12px] mt-0.5 mb-4 font-[600]">Riwayat transaksi kamu</p>
      </div>

      <div className="flex-1 overflow-y-auto px-5 pb-20 space-y-3">
        {ORDERS.map(o => (
          <div key={o.id} className="bg-card rounded-[18px] border border-border p-4">
            <div className="flex items-start justify-between mb-3">
              <div>
                <p className="text-[10.5px] text-muted-foreground font-mono font-[500]">{o.id}</p>
                <p className="text-[14px] font-[700] text-foreground mt-0.5">{o.product}</p>
              </div>
              <span className={`text-[10px] font-[800] px-2 py-1 rounded-full ${statusCls[o.status]}`}>
                {o.status}
              </span>
            </div>
            <div className="flex items-center justify-between text-[12px]">
              <span className="text-muted-foreground">{o.qty}x · {o.date}</span>
              <span className="font-[800] text-foreground">Rp {o.total.toLocaleString("id-ID")}</span>
            </div>
            {o.status === "Menunggu" && (
              <button onClick={() => go("siswa-qris")}
                className="w-full mt-3 py-2.5 bg-primary text-white text-[12px] font-[800] rounded-[12px]">
                Bayar Sekarang →
              </button>
            )}
          </div>
        ))}
      </div>

      <SiswaNav active="siswa-pesanan" go={go} />
    </div>
  );
}

// ── Screen: Siswa Profil ──────────────────────────────────────────────────────
function SiswaProfil({ go }: { go: (s: Screen) => void }) {
  const menuItems = [
    { Icon: ShoppingBag, label: "Riwayat Pesanan", action: () => go("siswa-pesanan") },
    { Icon: MessageSquare, label: "Bantuan & CS", action: () => {} },
    { Icon: Bell, label: "Notifikasi", action: () => {} },
    { Icon: Settings, label: "Pengaturan Akun", action: () => {} },
  ];

  return (
    <div className="relative h-full flex flex-col bg-background">
      <div className="bg-primary flex-shrink-0 relative overflow-hidden">
        <div className="absolute top-0 right-0 w-32 h-32 bg-white/10 rounded-full -translate-y-1/2 translate-x-1/3" />
        <StatusBar light />
        <div className="flex items-center justify-between px-5 mb-5">
          <h1 className="text-white font-[800] text-lg">Profil Saya</h1>
          <Settings className="w-5 h-5 text-white/70" />
        </div>
        <div className="flex items-center gap-4 px-5 pb-8">
          <div className="w-16 h-16 rounded-[18px] bg-white/20 flex items-center justify-center text-white font-[800] text-xl border border-white/30">AP</div>
          <div>
            <p className="text-white font-[800] text-[17px]">Andi Pratama</p>
            <p className="text-white/70 text-[12px] font-[600]">NIS: 2024001234</p>
            <p className="text-white/70 text-[12px] font-[600]">Teknik Elektronika • XII-A</p>
          </div>
        </div>
      </div>

      <div className="-mt-4 bg-background rounded-t-[28px] flex-1 overflow-y-auto pb-20">
        <div className="px-5 pt-5 grid grid-cols-3 gap-2.5 mb-5">
          {[["12", "Total Pesanan"], ["10", "Selesai"], ["Rp 420K", "Total Belanja"]].map(([v, l]) => (
            <div key={l} className="bg-card rounded-[14px] p-3 border border-border text-center">
              <p className="text-foreground font-[800] text-[15px]">{v}</p>
              <p className="text-muted-foreground text-[9.5px] mt-0.5 font-[600]">{l}</p>
            </div>
          ))}
        </div>

        <div className="px-5 space-y-2">
          {menuItems.map(({ Icon, label, action }) => (
            <button key={label} onClick={action}
              className="w-full bg-card rounded-[14px] border border-border p-3.5 flex items-center gap-3">
              <div className="w-9 h-9 rounded-[12px] bg-secondary flex items-center justify-center">
                <Icon className="w-4 h-4 text-primary" />
              </div>
              <span className="flex-1 text-left text-[13.5px] font-[700] text-foreground">{label}</span>
              <ChevronRight className="w-4 h-4 text-muted-foreground" />
            </button>
          ))}
          <button onClick={() => go("welcome")}
            className="w-full bg-red-50 rounded-[14px] border border-red-100 p-3.5 flex items-center gap-3">
            <div className="w-9 h-9 rounded-[12px] bg-red-100 flex items-center justify-center">
              <LogOut className="w-4 h-4 text-red-500" />
            </div>
            <span className="flex-1 text-left text-[13.5px] font-[700] text-red-600">Keluar</span>
          </button>
        </div>
      </div>

      <SiswaNav active="siswa-profil" go={go} />
    </div>
  );
}

// ── Screen: Checkout ──────────────────────────────────────────────────────────
function SiswaCheckout({ go, back }: { go: (s: Screen) => void; back: () => void }) {
  const [payment, setPayment] = useState("qris");
  const [qty, setQty] = useState(1);
  const p = PRODUCTS[0];
  const total = p.price * qty;

  const methods = [
    { id: "qris", label: "QRIS", sub: "e-wallet / mobile banking", Icon: QrCode },
    { id: "transfer", label: "Transfer Bank", sub: "BNI · BRI · Mandiri", Icon: Wallet },
    { id: "tunai", label: "Tunai", sub: "Bayar langsung ke admin", Icon: Tag },
  ];

  return (
    <div className="h-full flex flex-col bg-background">
      <div className="flex-shrink-0 px-5 pt-0">
        <StatusBar />
        <TopBar title="Checkout" onBack={back} />
      </div>

      <div className="flex-1 overflow-y-auto px-5 space-y-3 pb-4">
        {/* Product */}
        <div className="bg-card rounded-[18px] border border-border p-4 flex gap-3">
          <div className="w-16 h-16 rounded-[14px] overflow-hidden bg-muted flex-shrink-0">
            <img src={`https://images.unsplash.com/${p.img}?w=80&h=80&fit=crop&auto=format`} alt={p.name} className="w-full h-full object-cover" />
          </div>
          <div>
            <p className="text-[14px] font-[700] text-foreground">{p.name}</p>
            <p className="text-primary font-[800] text-[13px]">Rp {p.price.toLocaleString("id-ID")}</p>
            <p className="text-muted-foreground text-[11px] font-[600]">Teknik Elektronika</p>
          </div>
        </div>

        {/* Qty */}
        <div className="bg-card rounded-[18px] border border-border p-4">
          <p className="text-[12.5px] font-[700] text-foreground mb-3">Jumlah</p>
          <div className="flex items-center justify-between">
            <p className="text-muted-foreground text-[12px]">Stok: {p.stock}</p>
            <div className="flex items-center gap-3">
              <button onClick={() => setQty(q => Math.max(1, q - 1))}
                className="w-8 h-8 rounded-full bg-muted flex items-center justify-center font-[700] text-foreground text-lg leading-none">−</button>
              <span className="w-5 text-center font-[800] text-[15px] text-foreground">{qty}</span>
              <button onClick={() => setQty(q => Math.min(p.stock, q + 1))}
                className="w-8 h-8 rounded-full bg-primary flex items-center justify-center font-[700] text-white text-lg leading-none">+</button>
            </div>
          </div>
        </div>

        {/* Payment */}
        <div className="bg-card rounded-[18px] border border-border p-4">
          <p className="text-[12.5px] font-[700] text-foreground mb-3">Metode Pembayaran</p>
          <div className="space-y-2">
            {methods.map(({ id, label, sub, Icon }) => (
              <button key={id} onClick={() => setPayment(id)}
                className={`w-full flex items-center gap-3 p-3 rounded-[14px] border-2 transition-all ${
                  payment === id ? "border-primary bg-primary/5" : "border-transparent bg-muted"
                }`}>
                <div className={`w-9 h-9 rounded-[12px] flex items-center justify-center ${payment === id ? "bg-primary text-white" : "bg-card text-muted-foreground"}`}>
                  <Icon className="w-4 h-4" />
                </div>
                <div className="flex-1 text-left">
                  <p className={`text-[12.5px] font-[700] ${payment === id ? "text-primary" : "text-foreground"}`}>{label}</p>
                  <p className="text-muted-foreground text-[10.5px]">{sub}</p>
                </div>
                <div className={`w-4 h-4 rounded-full border-2 flex items-center justify-center ${payment === id ? "border-primary" : "border-border"}`}>
                  {payment === id && <div className="w-2 h-2 bg-primary rounded-full" />}
                </div>
              </button>
            ))}
          </div>
        </div>

        {/* Price breakdown */}
        <div className="bg-card rounded-[18px] border border-border p-4">
          <p className="text-[12.5px] font-[700] text-foreground mb-3">Ringkasan Harga</p>
          <div className="space-y-2 text-[12.5px]">
            <div className="flex justify-between">
              <span className="text-muted-foreground">{p.name} ×{qty}</span>
              <span className="text-foreground">Rp {(p.price * qty).toLocaleString("id-ID")}</span>
            </div>
            <div className="flex justify-between">
              <span className="text-muted-foreground">Biaya Layanan</span>
              <span className="text-accent font-[700]">Gratis</span>
            </div>
            <div className="border-t border-border pt-2 flex justify-between">
              <span className="font-[800] text-foreground">Total</span>
              <span className="font-[800] text-primary text-[14px]">Rp {total.toLocaleString("id-ID")}</span>
            </div>
          </div>
        </div>
      </div>

      <div className="flex-shrink-0 px-5 pb-8 pt-3 border-t border-border bg-background">
        <button onClick={() => go("siswa-qris")}
          className="w-full py-3.5 bg-primary rounded-[16px] font-[800] text-white text-[14.5px] shadow-lg shadow-primary/25">
          Konfirmasi · Rp {total.toLocaleString("id-ID")}
        </button>
      </div>
    </div>
  );
}

// ── Screen: QRIS ──────────────────────────────────────────────────────────────
function SiswaQRIS({ back }: { back: () => void }) {
  const [secs, setSecs] = useState(900);
  useEffect(() => {
    const t = setInterval(() => setSecs(s => Math.max(0, s - 1)), 1000);
    return () => clearInterval(t);
  }, []);
  const mm = String(Math.floor(secs / 60)).padStart(2, "0");
  const ss = String(secs % 60).padStart(2, "0");

  const QRVisual = () => (
    <svg viewBox="0 0 25 25" className="w-full h-full" style={{ imageRendering: "pixelated" }}>
      <rect width="25" height="25" fill="white"/>
      {/* Top-left finder */}
      <rect x="1" y="1" width="7" height="7" fill="#1A1D24"/>
      <rect x="2" y="2" width="5" height="5" fill="white"/>
      <rect x="3" y="3" width="3" height="3" fill="#1A1D24"/>
      {/* Top-right finder */}
      <rect x="17" y="1" width="7" height="7" fill="#1A1D24"/>
      <rect x="18" y="2" width="5" height="5" fill="white"/>
      <rect x="19" y="3" width="3" height="3" fill="#1A1D24"/>
      {/* Bottom-left finder */}
      <rect x="1" y="17" width="7" height="7" fill="#1A1D24"/>
      <rect x="2" y="18" width="5" height="5" fill="white"/>
      <rect x="3" y="19" width="3" height="3" fill="#1A1D24"/>
      {/* Data pixels */}
      {[[9,1],[11,1],[13,1],[15,1],[9,2],[12,2],[14,2],[10,3],[11,3],[13,3],[15,3],
        [9,4],[12,4],[14,4],[10,5],[13,5],[15,5],[9,6],[11,6],[12,6],[14,6],
        [1,9],[3,9],[5,9],[7,9],[9,9],[11,9],[13,9],[15,9],[17,9],[19,9],[21,9],[23,9],
        [1,10],[4,10],[7,10],[10,10],[12,10],[15,10],[18,10],[21,10],[23,10],
        [2,11],[3,11],[5,11],[8,11],[11,11],[14,11],[17,11],[20,11],[22,11],
        [1,12],[4,12],[6,12],[9,12],[12,12],[15,12],[17,12],[20,12],[23,12],
        [2,13],[5,13],[7,13],[10,13],[13,13],[16,13],[19,13],[21,13],[23,13],
        [9,17],[11,17],[13,17],[15,17],[17,17],[19,17],[21,17],[23,17],
        [9,18],[12,18],[14,18],[17,18],[20,18],[22,18],
        [10,19],[11,19],[13,19],[16,19],[18,19],[21,19],[23,19],
        [9,20],[12,20],[15,20],[17,20],[20,20],[22,20],
        [10,21],[13,21],[14,21],[16,21],[19,21],[21,21],[23,21],
        [9,22],[11,22],[13,22],[16,22],[18,22],[21,22],[23,22],
        [10,23],[12,23],[15,23],[17,23],[20,23],[22,23],
      ].map(([x, y]) => (
        <rect key={`${x}-${y}`} x={x} y={y} width="1" height="1" fill="#1A1D24"/>
      ))}
    </svg>
  );

  return (
    <div className="h-full flex flex-col bg-background">
      <div className="flex-shrink-0 px-5 pt-0">
        <StatusBar />
        <TopBar title="Pembayaran QRIS" onBack={back} />
      </div>

      <div className="flex-1 overflow-y-auto px-5 pb-4">
        <p className="text-center text-muted-foreground text-[12px] mb-4 font-[600]">
          Scan QR code ini dengan e-wallet atau m-banking
        </p>

        <div className="bg-card rounded-[24px] border-2 border-primary/15 p-5 mb-4 shadow-xl shadow-primary/5">
          <div className="flex items-center justify-between mb-3">
            <div className="flex items-center gap-2">
              <div className="w-6 h-6 bg-primary rounded-[8px] flex items-center justify-center">
                <Layers className="w-3.5 h-3.5 text-white" />
              </div>
              <span className="text-[11px] font-[800] text-primary">SMK Nusantara 1</span>
            </div>
            <span className="text-[9.5px] text-muted-foreground font-mono">NMID: 9310000001</span>
          </div>

          <div className="bg-white rounded-[18px] p-3 border border-border mb-3">
            <div className="w-44 h-44 mx-auto">
              <QRVisual />
            </div>
          </div>

          <div className="text-center">
            <p className="text-[24px] font-[800] text-foreground">Rp 85.000</p>
            <p className="text-muted-foreground text-[11.5px] mt-0.5 font-[600]">Arduino Uno R3 × 1</p>
          </div>
        </div>

        <div className="bg-amber-50 border border-amber-200 rounded-[16px] p-3.5 flex items-center gap-3 mb-4">
          <Clock className="w-5 h-5 text-amber-600 flex-shrink-0" />
          <div>
            <p className="text-amber-800 text-[11px] font-[700]">Selesaikan pembayaran dalam</p>
            <p className="text-amber-700 text-[20px] font-[800] font-mono leading-none mt-0.5">{mm}:{ss}</p>
          </div>
        </div>

        <div className="bg-card rounded-[16px] border border-border p-4 mb-3">
          <p className="text-[11px] text-muted-foreground font-[700] mb-2.5 text-center">Diterima oleh</p>
          <div className="flex flex-wrap gap-2 justify-center">
            {["GoPay", "OVO", "DANA", "LinkAja", "ShopeePay", "m-BCA", "BNI Mobile"].map(w => (
              <span key={w} className="px-2.5 py-1 bg-muted rounded-full text-[10.5px] font-[700] text-muted-foreground">{w}</span>
            ))}
          </div>
        </div>

        <p className="text-center text-muted-foreground text-[10.5px] font-mono">Ref: ORD-20260822-002</p>
      </div>
    </div>
  );
}

// ── Screen: Admin Dashboard ───────────────────────────────────────────────────
function AdminDashboard({ go }: { go: (s: Screen) => void }) {
  const metrics = [
    { label: "Total Produk", value: "48", Icon: Package, cls: "bg-primary/10 text-primary", note: "+3 minggu ini" },
    { label: "Stok Menipis", value: "3", Icon: AlertTriangle, cls: "bg-amber-100 text-amber-600", note: "Perlu restok segera" },
    { label: "Penjualan Hari Ini", value: "Rp 215K", Icon: TrendingUp, cls: "bg-accent/10 text-accent", note: "+12% vs kemarin" },
  ];

  const recentTx = [
    { product: "Arduino Uno R3", buyer: "Andi Pratama (XII-A)", amount: 85000, time: "10:32" },
    { product: "Breadboard 830T", buyer: "Dewi Sartika (XI-B)", amount: 50000, time: "09:15" },
    { product: "Resistor Set", buyer: "Rizky Aditya (X-C)", amount: 60000, time: "08:44" },
  ];

  return (
    <div className="relative h-full flex flex-col">
      <div className="bg-primary flex-shrink-0 relative overflow-hidden">
        <div className="absolute bottom-0 right-0 w-28 h-28 bg-white/10 rounded-full translate-y-1/2 translate-x-1/4" />
        <StatusBar light />
        <div className="px-5 pb-8">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-white/65 text-[11px] font-[600]">Dashboard Admin</p>
              <h1 className="text-white font-[800] text-[17px]">Teknik Elektronika</h1>
            </div>
            <div className="w-10 h-10 rounded-[14px] bg-white/20 flex items-center justify-center text-white font-[800] text-sm border border-white/20">BS</div>
          </div>
          <p className="text-white/55 text-[11px] mt-1 font-[600]">Budi Santoso, S.T. · Ketua Jurusan</p>
        </div>
      </div>

      <div className="-mt-4 bg-background rounded-t-[28px] flex-1 overflow-y-auto pb-20">
        {/* Metrics */}
        <div className="px-5 pt-5 space-y-2.5 mb-5">
          {metrics.map(({ label, value, Icon, cls, note }) => (
            <div key={label} className="bg-card rounded-[18px] border border-border p-4 flex items-center gap-4">
              <div className={`w-12 h-12 rounded-[16px] flex items-center justify-center flex-shrink-0 ${cls}`}>
                <Icon className="w-5 h-5" />
              </div>
              <div className="flex-1">
                <p className="text-muted-foreground text-[11.5px] font-[600]">{label}</p>
                <p className="text-foreground font-[800] text-[20px] leading-none mt-0.5">{value}</p>
                <p className="text-muted-foreground text-[10.5px] mt-0.5 font-[600]">{note}</p>
              </div>
              <ChevronRight className="w-4 h-4 text-muted-foreground" />
            </div>
          ))}
        </div>

        {/* Quick actions */}
        <div className="px-5 mb-5">
          <p className="text-[11.5px] font-[800] text-muted-foreground tracking-wider mb-3">AKSI CEPAT</p>
          <div className="grid grid-cols-3 gap-2.5">
            {[
              { Icon: Scan, label: "Scanner", bg: "bg-primary", action: () => go("admin-scanner") },
              { Icon: Plus, label: "Tambah Produk", bg: "bg-accent", action: () => go("admin-products") },
              { Icon: Users, label: "Tambah User", bg: "bg-[#8B5CF6]", action: () => go("admin-add-user") },
            ].map(({ Icon, label, bg, action }) => (
              <button key={label} onClick={action}
                className="flex flex-col items-center gap-2 p-3.5 bg-card rounded-[18px] border border-border">
                <div className={`w-11 h-11 rounded-[14px] ${bg} flex items-center justify-center shadow-md`}>
                  <Icon className="w-5 h-5 text-white" />
                </div>
                <span className="text-[10.5px] font-[700] text-foreground text-center leading-tight">{label}</span>
              </button>
            ))}
          </div>
        </div>

        {/* Recent transactions */}
        <div className="px-5 pb-4">
          <div className="flex items-center justify-between mb-3">
            <p className="text-[11.5px] font-[800] text-muted-foreground tracking-wider">TRANSAKSI HARI INI</p>
            <button className="text-primary text-[11.5px] font-[700]">Lihat Semua</button>
          </div>
          <div className="space-y-2">
            {recentTx.map((tx, i) => (
              <div key={i} className="bg-card rounded-[14px] border border-border p-3 flex items-center gap-3">
                <div className="w-9 h-9 rounded-[12px] bg-accent/10 flex items-center justify-center flex-shrink-0">
                  <Check className="w-4 h-4 text-accent" />
                </div>
                <div className="flex-1 min-w-0">
                  <p className="text-[12.5px] font-[700] text-foreground truncate">{tx.product}</p>
                  <p className="text-muted-foreground text-[10.5px] truncate">{tx.buyer}</p>
                </div>
                <div className="text-right flex-shrink-0">
                  <p className="text-accent font-[800] text-[11.5px]">+Rp {(tx.amount / 1000).toFixed(0)}K</p>
                  <p className="text-muted-foreground text-[10px] font-mono">{tx.time}</p>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>

      <AdminNav active="admin-dashboard" go={go} />
    </div>
  );
}

// ── Screen: Barcode Scanner ───────────────────────────────────────────────────
function AdminScanner({ go, back }: { go: (s: Screen) => void; back: () => void }) {
  const [scanned, setScanned] = useState(false);
  const [showMerge, setShowMerge] = useState(false);
  const [showCustom, setShowCustom] = useState(false);
  const [customQty, setCustomQty] = useState("");
  const [success, setSuccess] = useState(false);

  const handleScan = () => {
    setScanned(true);
    setTimeout(() => setShowMerge(true), 600);
  };

  const handleConfirm = () => {
    setShowMerge(false);
    setShowCustom(false);
    setSuccess(true);
    setTimeout(() => { setSuccess(false); setScanned(false); }, 2500);
  };

  return (
    <div className="relative h-full flex flex-col bg-[#07101F]">
      {/* Header */}
      <div className="flex-shrink-0">
        <div className="flex items-center justify-between px-5 pt-[52px] pb-3">
          <button onClick={back} className="w-9 h-9 rounded-full bg-white/10 flex items-center justify-center">
            <ChevronLeft className="w-5 h-5 text-white" />
          </button>
          <span className="text-white font-[700] text-[15px]">Scanner Barcode</span>
          <button className="w-9 h-9 rounded-full bg-white/10 flex items-center justify-center">
            <Zap className="w-4 h-4 text-white" />
          </button>
        </div>
      </div>

      {/* Camera area */}
      <div className="flex-1 flex flex-col items-center justify-center px-8 relative">
        <div className="absolute inset-0"
          style={{ backgroundImage: "repeating-linear-gradient(0deg, transparent, transparent 30px, rgba(255,255,255,0.02) 30px, rgba(255,255,255,0.02) 31px), repeating-linear-gradient(90deg, transparent, transparent 30px, rgba(255,255,255,0.02) 30px, rgba(255,255,255,0.02) 31px)" }} />

        {/* Viewfinder */}
        <div className="relative w-52 h-52">
          {["top-0 left-0 border-t-[3px] border-l-[3px]",
            "top-0 right-0 border-t-[3px] border-r-[3px]",
            "bottom-0 left-0 border-b-[3px] border-l-[3px]",
            "bottom-0 right-0 border-b-[3px] border-r-[3px]",
          ].map((cls, i) => (
            <div key={i} className={`absolute w-7 h-7 border-primary ${cls}`} />
          ))}
          <div className="absolute inset-0 overflow-hidden">
            {!scanned && (
              <div className="absolute left-0 right-0 h-0.5 bg-primary"
                style={{ animation: "scanLine 2s linear infinite", boxShadow: "0 0 10px 2px #1B5BFF" }} />
            )}
            {scanned && (
              <div className="absolute inset-0 bg-accent/20 flex items-center justify-center">
                <CheckCircle className="w-14 h-14 text-accent" />
              </div>
            )}
          </div>
        </div>

        <style>{`
          @keyframes scanLine {
            0%   { top: 0; }
            50%  { top: calc(100% - 2px); }
            100% { top: 0; }
          }
        `}</style>

        <p className="text-white/55 text-[12px] mt-6 text-center font-[600]">
          {scanned ? "Produk terdeteksi!" : "Arahkan kamera ke barcode / QR Code produk"}
        </p>

        <div className="flex items-center gap-2 mt-4">
          <input
            placeholder="Input manual kode produk..."
            className="bg-white/10 text-white text-[12px] placeholder-white/35 border border-white/15 rounded-[12px] px-3.5 py-2 w-44 focus:outline-none focus:border-primary"
          />
          <button className="bg-primary px-3.5 py-2 rounded-[12px] text-white text-[12px] font-[700]">Cari</button>
        </div>

        {!scanned && (
          <button onClick={handleScan}
            className="mt-5 bg-primary px-8 py-3 rounded-[18px] text-white text-[13px] font-[800] shadow-lg shadow-primary/40">
            Simulasi Scan
          </button>
        )}

        {success && (
          <div className="absolute top-3 left-3 right-3 bg-accent rounded-[16px] p-3.5 flex items-center gap-2.5 shadow-xl z-50">
            <CheckCircle className="w-5 h-5 text-white flex-shrink-0" />
            <p className="text-white font-[700] text-[13px]">Stok berhasil diperbarui!</p>
          </div>
        )}
      </div>

      <AdminNav active="admin-scanner" go={go} />

      {/* Merge popup */}
      {showMerge && (
        <div className="absolute inset-0 bg-black/60 flex items-end z-50">
          <div className="w-full bg-card rounded-t-[28px] p-6">
            <div className="w-10 h-1 bg-border rounded-full mx-auto mb-5" />
            <div className="flex items-center gap-3 mb-4">
              <div className="w-12 h-12 rounded-[16px] bg-accent/10 flex items-center justify-center">
                <CheckCircle className="w-6 h-6 text-accent" />
              </div>
              <div>
                <p className="text-[10px] font-[800] text-accent uppercase tracking-wider">Produk Ditemukan!</p>
                <p className="text-foreground font-[800] text-[16px]">Arduino Uno R3</p>
              </div>
            </div>

            <div className="bg-muted rounded-[14px] p-3.5 mb-5">
              <div className="flex justify-between text-[12.5px] mb-1">
                <span className="text-muted-foreground">Stok saat ini</span>
                <span className="font-[800] text-foreground">12 unit</span>
              </div>
              <div className="flex justify-between text-[12.5px]">
                <span className="text-muted-foreground">Harga satuan</span>
                <span className="font-[800] text-primary">Rp 85.000</span>
              </div>
            </div>

            <p className="text-[13px] font-[700] text-foreground text-center mb-3">
              Tambahkan ke stok saat ini?
            </p>

            {showCustom ? (
              <div className="mb-3">
                <input
                  type="number"
                  value={customQty}
                  onChange={e => setCustomQty(e.target.value)}
                  placeholder="Masukkan jumlah stok"
                  className="w-full border-2 border-primary rounded-[14px] px-4 py-3 text-center text-foreground font-[800] text-lg focus:outline-none"
                  autoFocus
                />
                <button onClick={handleConfirm}
                  className="w-full mt-3 py-3.5 bg-primary rounded-[14px] text-white font-[800] text-[13.5px]">
                  Konfirmasi +{customQty || "0"} Unit
                </button>
              </div>
            ) : (
              <div className="grid grid-cols-2 gap-2.5 mb-3">
                <button onClick={handleConfirm}
                  className="py-3.5 bg-primary rounded-[14px] text-white font-[800] text-[13px]">
                  + 1 ke Stok
                </button>
                <button onClick={() => setShowCustom(true)}
                  className="py-3.5 bg-secondary border-2 border-primary rounded-[14px] text-primary font-[800] text-[13px]">
                  Custom Jumlah
                </button>
              </div>
            )}

            <button onClick={() => { setShowMerge(false); setScanned(false); setShowCustom(false); }}
              className="w-full py-3 text-muted-foreground text-[12.5px] font-[700]">
              Batal
            </button>
          </div>
        </div>
      )}
    </div>
  );
}

// ── Screen: Add User & WA Notification ───────────────────────────────────────
function AdminAddUser({ go, back }: { go: (s: Screen) => void; back: () => void }) {
  const [form, setForm] = useState({ name: "", nis: "", wa: "", jurusan: "", role: "siswa" });
  const [submitted, setSubmitted] = useState(false);

  const handleSubmit = () => {
    setSubmitted(true);
    setTimeout(() => setSubmitted(false), 3500);
  };

  return (
    <div className="relative h-full flex flex-col bg-background">
      <div className="flex-shrink-0 px-5 pt-0">
        <StatusBar />
        <TopBar title="Tambah Pengguna" onBack={back} />
      </div>

      <div className="flex-1 overflow-y-auto px-5 pb-20 space-y-4">
        {/* Form */}
        <div className="bg-card rounded-[18px] border border-border p-4">
          <h2 className="text-[13.5px] font-[800] text-foreground mb-4">Data Pengguna Baru</h2>
          <div className="space-y-3">
            {[
              { key: "name", label: "Nama Lengkap", ph: "Masukkan nama lengkap" },
              { key: "nis", label: "NIS / ID Karyawan", ph: "Masukkan NIS" },
              { key: "wa", label: "Nomor WhatsApp", ph: "08xxxxxxxxxx" },
            ].map(({ key, label, ph }) => (
              <div key={key}>
                <label className="text-[11.5px] font-[700] text-muted-foreground mb-1.5 block">{label}</label>
                <input
                  type="text"
                  placeholder={ph}
                  value={form[key as keyof typeof form]}
                  onChange={e => setForm(f => ({ ...f, [key]: e.target.value }))}
                  className="w-full px-4 py-3 bg-muted border border-transparent rounded-[12px] text-[13px] text-foreground placeholder-muted-foreground focus:outline-none focus:border-primary focus:bg-card"
                />
              </div>
            ))}

            <div>
              <label className="text-[11.5px] font-[700] text-muted-foreground mb-1.5 block">Jurusan</label>
              <div className="relative">
                <select
                  value={form.jurusan}
                  onChange={e => setForm(f => ({ ...f, jurusan: e.target.value }))}
                  className="w-full px-4 py-3 bg-muted border border-transparent rounded-[12px] text-[13px] text-foreground appearance-none focus:outline-none focus:border-primary focus:bg-card"
                >
                  <option value="">Pilih jurusan...</option>
                  <option value="elektronika">Teknik Elektronika</option>
                  <option value="tkj">TKJ</option>
                  <option value="rpl">RPL</option>
                  <option value="taboga">Tata Boga</option>
                </select>
                <ChevronDown className="absolute right-4 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground pointer-events-none" />
              </div>
            </div>

            <div>
              <label className="text-[11.5px] font-[700] text-muted-foreground mb-1.5 block">Role</label>
              <div className="grid grid-cols-2 gap-2">
                {[["siswa", "Siswa"], ["admin", "Ketua Jurusan"]].map(([r, label]) => (
                  <button key={r} onClick={() => setForm(f => ({ ...f, role: r }))}
                    className={`py-2.5 rounded-[12px] text-[12px] font-[700] border-2 transition-all ${
                      form.role === r ? "border-primary bg-primary/5 text-primary" : "border-transparent bg-muted text-muted-foreground"
                    }`}>
                    {label}
                  </button>
                ))}
              </div>
            </div>
          </div>

          <button onClick={handleSubmit}
            className="w-full mt-5 py-3.5 bg-primary rounded-[14px] text-white font-[800] text-[13.5px] shadow-md shadow-primary/20 flex items-center justify-center gap-2">
            <Send className="w-4 h-4" />
            Daftarkan &amp; Kirim Notif WA
          </button>

          {submitted && (
            <div className="mt-3 p-3.5 bg-accent/10 rounded-[12px] border border-accent/20 flex items-center gap-2.5">
              <CheckCircle className="w-4 h-4 text-accent" />
              <p className="text-accent text-[11.5px] font-[700]">Didaftarkan! Notifikasi WA terkirim otomatis.</p>
            </div>
          )}
        </div>

        {/* WA Log */}
        <div>
          <div className="flex items-center justify-between mb-3">
            <p className="text-[13px] font-[800] text-foreground">Log Notifikasi WhatsApp</p>
            <button className="w-7 h-7 rounded-[10px] bg-muted flex items-center justify-center">
              <RefreshCw className="w-3.5 h-3.5 text-muted-foreground" />
            </button>
          </div>

          <div className="space-y-2">
            {WA_LOGS.map(log => (
              <div key={log.id} className="bg-card rounded-[14px] border border-border p-3 flex items-center gap-3">
                <div className="w-8 h-8 rounded-[10px] bg-[#25D366]/10 flex items-center justify-center flex-shrink-0">
                  <MessageSquare className="w-4 h-4 text-[#25D366]" />
                </div>
                <div className="flex-1 min-w-0">
                  <p className="text-[12px] font-[700] text-foreground truncate">{log.user}</p>
                  <p className="text-muted-foreground text-[10.5px] truncate">{log.msg}</p>
                </div>
                <div className="text-right flex-shrink-0">
                  <p className="text-muted-foreground text-[10px] font-mono">{log.time}</p>
                  <span className={`text-[9px] font-[800] px-1.5 py-0.5 rounded-full ${
                    log.status === "delivered" ? "bg-accent/10 text-accent" : "bg-amber-100 text-amber-600"
                  }`}>
                    {log.status === "delivered" ? "Terkirim" : "Dikirim"}
                  </span>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>

      <AdminNav active="admin-add-user" go={go} />
    </div>
  );
}

// ── Screen: Admin Products ────────────────────────────────────────────────────
function AdminProducts({ go, back }: { go: (s: Screen) => void; back: () => void }) {
  const [products, setProducts] = useState(PRODUCTS);

  return (
    <div className="relative h-full flex flex-col bg-background">
      <div className="flex-shrink-0 px-5 pt-0">
        <StatusBar />
        <div className="flex items-center justify-between py-2">
          <h1 className="text-[20px] font-[800] text-foreground">Kelola Produk</h1>
          <button className="w-9 h-9 rounded-[12px] bg-primary flex items-center justify-center">
            <Plus className="w-4.5 h-4.5 text-white" />
          </button>
        </div>
        <div className="text-[12px] text-muted-foreground font-[600] mb-3">{products.length} produk terdaftar</div>
      </div>

      <div className="flex-1 overflow-y-auto px-5 pb-20 space-y-2.5">
        {products.map(p => (
          <div key={p.id} className="bg-card rounded-[16px] border border-border p-3 flex items-center gap-3">
            <div className="w-14 h-14 rounded-[12px] overflow-hidden bg-muted flex-shrink-0">
              <img src={`https://images.unsplash.com/${p.img}?w=64&h=64&fit=crop&auto=format`} alt={p.name} className="w-full h-full object-cover" />
            </div>
            <div className="flex-1 min-w-0">
              <p className="text-[12.5px] font-[700] text-foreground truncate">{p.name}</p>
              <p className="text-primary text-[12px] font-[800]">Rp {p.price.toLocaleString("id-ID")}</p>
              <span className={`inline-block text-[9.5px] font-[800] px-1.5 py-0.5 rounded-full mt-0.5 ${
                p.stock === 0 ? "bg-red-100 text-red-500" :
                p.stock <= 5 ? "bg-amber-100 text-amber-600" :
                "bg-accent/10 text-accent"
              }`}>
                {p.stock === 0 ? "Habis" : `Stok: ${p.stock}`}
              </span>
            </div>
            <div className="flex flex-col gap-1.5 flex-shrink-0">
              <button className="w-8 h-8 rounded-[10px] bg-primary/10 flex items-center justify-center">
                <Edit className="w-3.5 h-3.5 text-primary" />
              </button>
              <button onClick={() => setProducts(prev => prev.filter(x => x.id !== p.id))}
                className="w-8 h-8 rounded-[10px] bg-red-50 flex items-center justify-center">
                <Trash2 className="w-3.5 h-3.5 text-red-500" />
              </button>
            </div>
          </div>
        ))}
      </div>

      <AdminNav active="admin-products" go={go} />
    </div>
  );
}

// ── Screen: Hubin Dashboard ───────────────────────────────────────────────────
function HubinDashboard({ go }: { go: (s: Screen) => void }) {
  const totalRev = DEPARTMENTS.reduce((s, d) => s + d.todaySales, 0);

  return (
    <div className="relative h-full flex flex-col">
      <div className="bg-[#6D28D9] flex-shrink-0 relative overflow-hidden">
        <div className="absolute top-0 right-0 w-40 h-40 bg-white/10 rounded-full -translate-y-1/2 translate-x-1/3" />
        <div className="absolute bottom-0 left-0 w-24 h-24 bg-white/10 rounded-full translate-y-1/2 -translate-x-1/3" />
        <StatusBar light />
        <div className="px-5 pb-8 relative z-10">
          <div className="flex items-center justify-between mb-1">
            <div>
              <p className="text-white/60 text-[11px] font-[600]">Super Admin · Hubin</p>
              <h1 className="text-white font-[800] text-[18px]">Hubin Panel</h1>
            </div>
            <div className="w-10 h-10 rounded-[14px] bg-white/20 flex items-center justify-center text-white font-[800] text-sm border border-white/20">HB</div>
          </div>
          <p className="text-white/50 text-[11px] font-[600]">Hub. Industri · SMK Nusantara 1 Yogyakarta</p>
        </div>
      </div>

      <div className="-mt-4 bg-background rounded-t-[28px] flex-1 overflow-y-auto pb-20">
        <div className="px-5 pt-5 grid grid-cols-2 gap-2.5 mb-5">
          {[
            { label: "Total Jurusan", value: "6", Icon: Layers, cls: "text-[#7C3AED] bg-[#7C3AED]/10" },
            { label: "Total Produk", value: "234", Icon: Package, cls: "text-primary bg-primary/10" },
            { label: "Revenue Hari Ini", value: `Rp ${(totalRev / 1000).toFixed(0)}K`, Icon: TrendingUp, cls: "text-accent bg-accent/10" },
            { label: "Order Aktif", value: "18", Icon: ShoppingCart, cls: "text-amber-600 bg-amber-100" },
          ].map(({ label, value, Icon, cls }) => (
            <div key={label} className="bg-card rounded-[18px] border border-border p-4">
              <div className={`w-10 h-10 rounded-[13px] flex items-center justify-center mb-2.5 ${cls}`}>
                <Icon className="w-5 h-5" />
              </div>
              <p className="text-foreground font-[800] text-[18px] leading-none">{value}</p>
              <p className="text-muted-foreground text-[10.5px] mt-1 font-[600]">{label}</p>
            </div>
          ))}
        </div>

        <div className="px-5 mb-5 grid grid-cols-2 gap-2.5">
          <button onClick={() => go("hubin-admins")}
            className="bg-[#7C3AED]/5 border border-[#7C3AED]/20 rounded-[18px] p-4 flex items-center gap-3 text-left">
            <div className="w-10 h-10 rounded-[13px] bg-[#7C3AED] flex items-center justify-center flex-shrink-0">
              <Users className="w-5 h-5 text-white" />
            </div>
            <div>
              <p className="text-[12.5px] font-[800] text-foreground">Kelola Admin</p>
              <p className="text-[10.5px] text-muted-foreground">{ADMINS_DATA.length} aktif</p>
            </div>
          </button>
          <button onClick={() => go("hubin-reports")}
            className="bg-accent/5 border border-accent/20 rounded-[18px] p-4 flex items-center gap-3 text-left">
            <div className="w-10 h-10 rounded-[13px] bg-accent flex items-center justify-center flex-shrink-0">
              <BarChart2 className="w-5 h-5 text-white" />
            </div>
            <div>
              <p className="text-[12.5px] font-[800] text-foreground">Laporan</p>
              <p className="text-[10.5px] text-muted-foreground">Export PDF/Excel</p>
            </div>
          </button>
        </div>

        <div className="px-5 pb-4">
          <p className="text-[11.5px] font-[800] text-muted-foreground tracking-wider mb-3">PERFORMA JURUSAN</p>
          <div className="space-y-2.5">
            {DEPARTMENTS.map((dept, i) => (
              <div key={i} className="bg-card rounded-[16px] border border-border p-4">
                <div className="flex items-center justify-between mb-2">
                  <div className="flex items-center gap-2.5">
                    <div className="w-2.5 h-2.5 rounded-full flex-shrink-0" style={{ backgroundColor: dept.color }} />
                    <p className="text-[12.5px] font-[700] text-foreground">{dept.name}</p>
                  </div>
                  <span className="text-accent font-[800] text-[12px]">
                    +Rp {(dept.todaySales / 1000).toFixed(0)}K
                  </span>
                </div>
                <div className="flex items-center gap-2 text-[10.5px]">
                  <span className="text-muted-foreground w-16 flex-shrink-0">{dept.products} produk</span>
                  <div className="flex-1 h-1.5 bg-muted rounded-full overflow-hidden">
                    <div className="h-full rounded-full transition-all"
                      style={{ width: `${(dept.todaySales / (totalRev || 1)) * 100}%`, backgroundColor: dept.color }} />
                  </div>
                  <span className="text-muted-foreground flex-shrink-0 w-8 text-right">
                    {Math.round((dept.todaySales / (totalRev || 1)) * 100)}%
                  </span>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>

      <HubinNav active="hubin-dashboard" go={go} />
    </div>
  );
}

// ── Screen: Manage Admins ─────────────────────────────────────────────────────
function HubinManageAdmins({ go, back }: { go: (s: Screen) => void; back: () => void }) {
  const [admins, setAdmins] = useState(ADMINS_DATA);

  return (
    <div className="relative h-full flex flex-col bg-background">
      <div className="flex-shrink-0 px-5 pt-0">
        <StatusBar />
        <div className="flex items-center justify-between py-2 mb-1">
          <h1 className="text-[20px] font-[800] text-foreground">Kelola Admin</h1>
          <button className="flex items-center gap-1.5 bg-[#7C3AED] rounded-[12px] px-3 py-2">
            <Plus className="w-4 h-4 text-white" />
            <span className="text-white text-[11.5px] font-[800]">Tambah</span>
          </button>
        </div>
        <p className="text-muted-foreground text-[12px] font-[600] mb-4">{admins.length} admin terdaftar</p>
      </div>

      <div className="flex-1 overflow-y-auto px-5 pb-20 space-y-3">
        {admins.map(a => (
          <div key={a.id} className="bg-card rounded-[18px] border border-border p-4">
            <div className="flex items-start gap-3 mb-3.5">
              <div className="w-11 h-11 rounded-[14px] flex items-center justify-center font-[800] text-sm flex-shrink-0 border"
                style={{ backgroundColor: `${a.color}18`, color: a.color, borderColor: `${a.color}30` }}>
                {a.initials}
              </div>
              <div className="flex-1 min-w-0">
                <p className="text-[13.5px] font-[800] text-foreground">{a.name}</p>
                <p className="text-muted-foreground text-[11px] font-[600]">{a.dept}</p>
                <div className="flex items-center gap-1.5 mt-1">
                  <div className="w-1.5 h-1.5 rounded-full bg-accent" />
                  <p className="text-[10px] text-muted-foreground font-[600]">Aktif {a.lastActive}</p>
                </div>
              </div>
            </div>
            <div className="flex gap-2">
              <button className="flex-1 py-2.5 bg-primary/10 text-primary rounded-[12px] text-[11.5px] font-[800] flex items-center justify-center gap-1.5">
                <Edit className="w-3.5 h-3.5" />
                Edit Akses
              </button>
              <button onClick={() => setAdmins(prev => prev.filter(x => x.id !== a.id))}
                className="flex-1 py-2.5 bg-red-50 text-red-500 rounded-[12px] text-[11.5px] font-[800] flex items-center justify-center gap-1.5">
                <Trash2 className="w-3.5 h-3.5" />
                Hapus
              </button>
            </div>
          </div>
        ))}
        {admins.length === 0 && (
          <div className="text-center py-16">
            <Users className="w-12 h-12 text-muted mx-auto mb-3" />
            <p className="text-muted-foreground text-sm font-[700]">Belum ada admin terdaftar</p>
          </div>
        )}
      </div>

      <HubinNav active="hubin-admins" go={go} />
    </div>
  );
}

// ── Screen: Sales Reports ─────────────────────────────────────────────────────
function HubinReports({ go, back }: { go: (s: Screen) => void; back: () => void }) {
  const [filter, setFilter] = useState<"daily" | "monthly">("daily");

  const chartData = filter === "daily"
    ? SALES_DAILY.map(d => ({ label: d.day, value: d.value }))
    : SALES_MONTHLY.map(d => ({ label: d.month, value: d.value }));

  const totalShown = TRANSACTIONS.reduce((s, t) => s + t.amount, 0);

  return (
    <div className="relative h-full flex flex-col bg-background">
      <div className="flex-shrink-0 px-5 pt-0">
        <StatusBar />
        <div className="flex items-center justify-between py-2 mb-1">
          <h1 className="text-[20px] font-[800] text-foreground">Laporan Penjualan</h1>
          <button className="flex items-center gap-1.5 bg-accent rounded-[12px] px-3 py-2">
            <Download className="w-3.5 h-3.5 text-white" />
            <span className="text-white text-[11.5px] font-[800]">Export</span>
          </button>
        </div>
      </div>

      <div className="flex-1 overflow-y-auto px-5 pb-20 space-y-4">
        {/* Filter */}
        <div className="bg-muted rounded-[16px] p-1 flex">
          {(["daily", "monthly"] as const).map(f => (
            <button key={f} onClick={() => setFilter(f)}
              className={`flex-1 py-2.5 rounded-[13px] text-[11.5px] font-[800] transition-all ${
                filter === f ? "bg-card text-foreground shadow-sm" : "text-muted-foreground"
              }`}>
              {f === "daily" ? "Harian (Minggu Ini)" : "Bulanan (2026)"}
            </button>
          ))}
        </div>

        {/* Summary */}
        <div className="grid grid-cols-2 gap-2.5">
          <div className="bg-card rounded-[16px] border border-border p-4">
            <TrendingUp className="w-5 h-5 text-accent mb-2" />
            <p className="text-foreground font-[800] text-[17px]">Rp {(totalShown / 1000).toFixed(0)}K</p>
            <p className="text-muted-foreground text-[10.5px] font-[600]">Hari ini</p>
          </div>
          <div className="bg-card rounded-[16px] border border-border p-4">
            <ShoppingCart className="w-5 h-5 text-primary mb-2" />
            <p className="text-foreground font-[800] text-[17px]">{TRANSACTIONS.length}</p>
            <p className="text-muted-foreground text-[10.5px] font-[600]">Transaksi</p>
          </div>
        </div>

        {/* Chart */}
        <div className="bg-card rounded-[18px] border border-border p-4">
          <p className="text-[12.5px] font-[800] text-foreground mb-3">
            {filter === "daily" ? "Penjualan 7 Hari Terakhir" : "Penjualan Bulanan 2026"}
          </p>
          <div className="h-36">
            <ResponsiveContainer width="100%" height="100%">
              <ReBarChart data={chartData} barSize={filter === "daily" ? 22 : 20}>
                <CartesianGrid strokeDasharray="3 3" stroke="rgba(0,0,0,0.04)" vertical={false} />
                <XAxis dataKey="label" tick={{ fontSize: 10, fill: "#6B7589", fontWeight: 600 }} axisLine={false} tickLine={false} />
                <YAxis hide />
                <Tooltip
                  formatter={(v: number) => [`Rp ${(v / 1000).toFixed(0)}K`, "Penjualan"]}
                  contentStyle={{ fontSize: 11, borderRadius: 10, border: "1px solid rgba(0,0,0,0.07)", fontFamily: "Nunito" }}
                />
                <Bar dataKey="value" fill="#1B5BFF" radius={[5, 5, 0, 0]} />
              </ReBarChart>
            </ResponsiveContainer>
          </div>
        </div>

        {/* Transaction list */}
        <div>
          <div className="flex items-center justify-between mb-3">
            <p className="text-[12.5px] font-[800] text-foreground">Detail Transaksi</p>
            <button className="flex items-center gap-1 text-muted-foreground text-[11.5px] font-[600]">
              <Filter className="w-3.5 h-3.5" /> Filter
            </button>
          </div>
          <div className="space-y-2">
            {TRANSACTIONS.map(tx => (
              <div key={tx.id} className="bg-card rounded-[14px] border border-border p-3 flex items-center gap-3">
                <div className="w-9 h-9 rounded-[12px] bg-accent/10 flex items-center justify-center flex-shrink-0">
                  <Check className="w-4 h-4 text-accent" />
                </div>
                <div className="flex-1 min-w-0">
                  <p className="text-[12px] font-[700] text-foreground truncate">{tx.product}</p>
                  <p className="text-muted-foreground text-[10.5px]">{tx.dept} · {tx.time}</p>
                </div>
                <div className="text-right flex-shrink-0">
                  <p className="text-accent font-[800] text-[12px]">+Rp {(tx.amount / 1000).toFixed(0)}K</p>
                  <p className="text-muted-foreground text-[9.5px] font-mono">{tx.id}</p>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>

      <HubinNav active="hubin-reports" go={go} />
    </div>
  );
}

// ── Main App ──────────────────────────────────────────────────────────────────
export default function App() {
  const [screen, setScreen] = useState<Screen>("welcome");
  const [history, setHistory] = useState<Screen[]>([]);

  const go = (to: Screen) => {
    setHistory(h => [...h, screen]);
    setScreen(to);
  };

  const back = () => {
    setHistory(h => {
      if (h.length === 0) return h;
      setScreen(h[h.length - 1]);
      return h.slice(0, -1);
    });
  };

  const quickNav: { label: string; s: Screen; group: string }[] = [
    { label: "Welcome", s: "welcome", group: "auth" },
    { label: "Login", s: "login", group: "auth" },
    { label: "Beranda", s: "siswa-home", group: "siswa" },
    { label: "Checkout", s: "siswa-checkout", group: "siswa" },
    { label: "QRIS", s: "siswa-qris", group: "siswa" },
    { label: "Dashboard", s: "admin-dashboard", group: "admin" },
    { label: "Scanner", s: "admin-scanner", group: "admin" },
    { label: "Pengguna", s: "admin-add-user", group: "admin" },
    { label: "Hubin", s: "hubin-dashboard", group: "hubin" },
    { label: "Admins", s: "hubin-admins", group: "hubin" },
    { label: "Laporan", s: "hubin-reports", group: "hubin" },
  ];

  const groupColors: Record<string, string> = {
    auth: "bg-white/10 text-white/55 hover:bg-white/20",
    siswa: "bg-primary/20 text-primary hover:bg-primary/30",
    admin: "bg-accent/20 text-accent hover:bg-accent/30",
    hubin: "bg-[#7C3AED]/20 text-[#A78BFA] hover:bg-[#7C3AED]/30",
  };

  const activeGroupColors: Record<string, string> = {
    auth: "bg-white text-[#0A0F1E]",
    siswa: "bg-primary text-white",
    admin: "bg-accent text-white",
    hubin: "bg-[#7C3AED] text-white",
  };

  const currentGroup = quickNav.find(n => n.s === screen)?.group ?? "auth";

  const renderScreen = () => {
    switch (screen) {
      case "welcome": return <WelcomeScreen go={go} />;
      case "login": return <LoginScreen go={go} back={back} />;
      case "siswa-home": return <SiswaHome go={go} />;
      case "siswa-katalog": return <SiswaKatalog go={go} />;
      case "siswa-pesanan": return <SiswaPesanan go={go} />;
      case "siswa-profil": return <SiswaProfil go={go} />;
      case "siswa-checkout": return <SiswaCheckout go={go} back={back} />;
      case "siswa-qris": return <SiswaQRIS back={back} />;
      case "admin-dashboard": return <AdminDashboard go={go} />;
      case "admin-scanner": return <AdminScanner go={go} back={back} />;
      case "admin-add-user": return <AdminAddUser go={go} back={back} />;
      case "admin-products": return <AdminProducts go={go} back={back} />;
      case "hubin-dashboard": return <HubinDashboard go={go} />;
      case "hubin-admins": return <HubinManageAdmins go={go} back={back} />;
      case "hubin-reports": return <HubinReports go={go} back={back} />;
      default: return <WelcomeScreen go={go} />;
    }
  };

  return (
    <div className="min-h-screen flex flex-col items-center justify-start bg-[#07101F] py-6 px-4">
      {/* Background glows */}
      <div className="fixed inset-0 overflow-hidden pointer-events-none">
        <div className="absolute top-1/4 -left-1/4 w-96 h-96 bg-primary/8 rounded-full blur-3xl" />
        <div className="absolute bottom-1/4 -right-1/4 w-72 h-72 bg-[#7C3AED]/8 rounded-full blur-3xl" />
        <div className="absolute top-3/4 left-1/4 w-64 h-64 bg-accent/6 rounded-full blur-3xl" />
      </div>

      {/* App title */}
      <div className="relative z-10 text-center mb-5">
        <p className="text-white/30 text-[10px] font-[700] tracking-[0.2em] uppercase">SMK Nusantara 1 · Yogyakarta</p>
        <h1 className="text-white/70 text-[13px] font-[800] mt-0.5">Marketplace &amp; Inventori Jurusan</h1>
      </div>

      {/* Phone frame */}
      <div
        className="relative z-10 w-[390px] rounded-[44px] overflow-hidden border border-[#1E2A3A] flex-shrink-0"
        style={{
          height: "780px",
          boxShadow: "0 40px 100px rgba(0,0,0,0.7), 0 0 0 1px rgba(255,255,255,0.04), inset 0 0 0 1px rgba(255,255,255,0.02)",
        }}
      >
        {/* Dynamic Island */}
        <div className="absolute top-0 left-1/2 -translate-x-1/2 w-[120px] h-[35px] bg-black rounded-b-[22px] z-50 flex items-center justify-center gap-2.5">
          <div className="w-14 h-[14px] bg-[#111] rounded-full" />
          <div className="w-3 h-3 bg-[#111] rounded-full" />
        </div>

        {/* Screen */}
        <div className="h-full w-full bg-background">
          {renderScreen()}
        </div>

        {/* Home indicator */}
        <div className="absolute bottom-2 left-1/2 -translate-x-1/2 w-28 h-1 bg-foreground/15 rounded-full pointer-events-none z-40" />
      </div>

      {/* Quick nav */}
      <div className="relative z-10 mt-5 w-[390px]">
        <p className="text-white/25 text-[9.5px] text-center mb-2.5 font-[700] tracking-[0.15em] uppercase">Navigasi Cepat</p>
        <div className="flex flex-wrap justify-center gap-1.5">
          {quickNav.map(({ label, s, group }) => {
            const isActive = screen === s;
            const cls = isActive ? activeGroupColors[group] : groupColors[group];
            return (
              <button
                key={s}
                onClick={() => { setHistory([]); setScreen(s); }}
                className={`px-2.5 py-1 rounded-full text-[10px] font-[700] transition-all ${cls}`}
              >
                {label}
              </button>
            );
          })}
        </div>
        <div className="flex justify-center gap-4 mt-3 text-[9.5px] font-[700]">
          <span className="text-primary/70">● Siswa</span>
          <span className="text-accent/70">● Admin</span>
          <span className="text-[#A78BFA]/70">● Hubin</span>
        </div>
      </div>
    </div>
  );
}
