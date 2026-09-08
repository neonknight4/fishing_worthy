/// Custom stroke ikone za bottom navigaciju (outline + filled).
/// Renderuju se preko flutter_svg; boja ide preko colorFilter (currentColor).
class NavIcon {
  final String outline;
  final String filled;
  const NavIcon(this.outline, this.filled);
}

const navIcons = <NavIcon>[
  // 1 · Početna
  NavIcon(
    '<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 11 12 3.5 21 11"/><path d="M5.5 9.5V20.5h13V9.5"/><path d="M10 20.5v-6h4v6"/></svg>',
    '<svg width="24" height="24" viewBox="0 0 24 24" fill="currentColor" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 3 3 10.5V21h6v-6h6v6h6V10.5L12 3Z"/></svg>',
  ),
  // 2 · Mapa
  NavIcon(
    '<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M9 4 3.5 6v13.5l5.5-2 6 2 5.5-2V4l-5.5 2-6-2Z"/><path d="M9 4v13.5"/><path d="M15 6v13.5"/></svg>',
    '<svg width="24" height="24" viewBox="0 0 24 24" fill="currentColor" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M8.7 3.2 2.9 5.3A1 1 0 0 0 2.2 6.3v13.4a1 1 0 0 0 1.3 1l5.2-1.9V3.2Zm1.6 0v15.6l4.4 1.5V4.7l-4.4-1.5Zm6 1.5v15.6l4.5-1.6a1 1 0 0 0 .7-1V4a1 1 0 0 0-1.3-1l-3.9 1.4Z"/></svg>',
  ),
  // 3 · Škola (diplomska kapa + traka)
  NavIcon(
    '<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 3.8 2.6 8.2 12 12.6l9.4-4.4L12 3.8Z"/><path d="M6.6 10.4v4.4c0 1.7 2.4 3 5.4 3s5.4-1.3 5.4-3v-4.4"/><path d="M21.4 8.4v5.2"/></svg>',
    '<svg width="24" height="24" viewBox="0 0 24 24" fill="currentColor" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 3.8 2.6 8.2 12 12.6l9.4-4.4L12 3.8Z"/><path d="M6.6 10.4v4.4c0 1.7 2.4 3 5.4 3s5.4-1.3 5.4-3v-4.4" fill="none"/><path d="M21.4 8.4v5.2" fill="none"/></svg>',
  ),
  // 4 · Traper (prodavnica / tezga)
  NavIcon(
    '<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 10h16"/><path d="M4.8 10 5.8 5.5h12.4L19.2 10"/><path d="M8.5 10V5.5"/><path d="M12 10V5.5"/><path d="M15.5 10V5.5"/><path d="M5.5 10.5V20h13v-9.5"/><path d="M10 20v-4.5h4V20"/></svg>',
    '<svg width="24" height="24" viewBox="0 0 24 24" fill="currentColor" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M5.5 4.8h13l1.3 5.2H4.2L5.5 4.8Z"/><path fill-rule="evenodd" clip-rule="evenodd" d="M5.6 11.2h12.8V20h-4.1v-4.4H9.7V20H5.6V11.2Z"/></svg>',
  ),
  // 5 · Dnevnik
  NavIcon(
    '<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M5 4.5A1.5 1.5 0 0 1 6.5 3H19v14.5H6.5A1.5 1.5 0 0 0 5 19V4.5Z"/><path d="M5 19a1.5 1.5 0 0 1 1.5-1.5H19V21H6.5A1.5 1.5 0 0 1 5 19.5"/><path d="M9 7.5h6"/><path d="M9 10.5h4"/></svg>',
    '<svg width="24" height="24" viewBox="0 0 24 24" fill="currentColor" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M19 2.2H6.5A2.3 2.3 0 0 0 4.2 4.5v15A2.3 2.3 0 0 1 6.5 17.2H19a.8.8 0 0 0 .8-.8V3a.8.8 0 0 0-.8-.8ZM19 18.8H6.5a.8.8 0 0 0-.8.8.8.8 0 0 0 .8.8H19a.8.8 0 0 0 .8-.8V18a.8.8 0 0 1-.8.8Z"/></svg>',
  ),
];
