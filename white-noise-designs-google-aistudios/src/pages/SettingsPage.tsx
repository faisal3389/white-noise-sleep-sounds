export default function SettingsPage() {
  return (
    <div className="pt-24 pb-40 px-6 max-w-5xl mx-auto">
      <h2 className="font-headline text-4xl font-extrabold tracking-tight mb-8">Settings</h2>
      <div className="space-y-6">
        <div className="p-6 rounded-2xl bg-surface-container-high border border-white/5">
          <h3 className="font-headline font-bold text-lg mb-4">Account</h3>
          <p className="text-on-surface-variant">Manage your profile and subscription.</p>
        </div>
        <div className="p-6 rounded-2xl bg-surface-container-high border border-white/5">
          <h3 className="font-headline font-bold text-lg mb-4">Audio Quality</h3>
          <p className="text-on-surface-variant">Choose your preferred streaming quality.</p>
        </div>
        <div className="p-6 rounded-2xl bg-surface-container-high border border-white/5">
          <h3 className="font-headline font-bold text-lg mb-4">Appearance</h3>
          <p className="text-on-surface-variant">Customize the look and feel of Ethereal.</p>
        </div>
      </div>
    </div>
  );
}
