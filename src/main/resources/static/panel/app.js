(() => {
  'use strict';

  const POLL_MS = 5000;
  const MAX_BACKOFF_MS = 30000;
  const PIXEL_SHIFT_MS = 5 * 60 * 1000;
  const REQUESTER_ID = 'wall-panel';
  const GRAFANA_PORT = 30300;
  const NODE_RED_PORT = 31880;
  const BRIGHTNESS_POLL_MS = 1500;
  const WAKE_THROTTLE_MS = 3000;
  const CELSIUS_REVERT_MS = 10000;
  const SCREENSAVER_MOVE_MS = 5 * 60 * 1000;
  const GRAFANA_DASHBOARD_PATH = '/d-solo/smarthouse-1809-jackson-st/1809-jackson-st-hollywood-fl';

  const state = {
    data: null,
    activeTab: 'controls',
    chartMode: localStorage.getItem('panel.chartMode') || 'all',
    chartRange: localStorage.getItem('panel.chartRange') || '6h',
    useFahrenheit: true,
    unitRevertTimer: null,
    backoffMs: POLL_MS,
    pollTimer: null,
    lockTargetCode: null,
    pendingAcSettingC: null,
    acDebounceTimer: null,
    lastWakeSentAt: 0,
    uiBrightness: 0.72,
    activeUiBrightness: 0.72,
    localWakeUntil: 0,
    screensaverActive: false,
    screensaverMoveTimer: null,
    ssPos: { x: null, y: null },
    busy: false
  };

  const el = {
    panelRoot: document.getElementById('panelRoot'),
    clockTime: document.getElementById('clockTime'),
    clockDate: document.getElementById('clockDate'),
    tabControlsBtn: document.getElementById('tabControlsBtn'),
    tabChartsBtn: document.getElementById('tabChartsBtn'),
    controlsView: document.getElementById('controlsView'),
    chartsView: document.getElementById('chartsView'),
    chartsGrid: document.getElementById('chartsGrid'),
    chartsRefreshBtn: document.getElementById('chartsRefreshBtn'),
    outdoorBadge: document.getElementById('outdoorBadge'),
    connDot: document.getElementById('connDot'),
    unitToggleBtn: document.getElementById('unitToggleBtn'),
    fsBtn: document.getElementById('fsBtn'),

    acCard: document.getElementById('acCard'),
    acStatusPill: document.getElementById('acStatusPill'),
    acLockBtn: document.getElementById('acLockBtn'),
    acLockLabel: document.getElementById('acLockLabel'),
    acActualValue: document.getElementById('acActualValue'),
    acActualUnit: document.getElementById('acActualUnit'),
    acSetValue: document.getElementById('acSetValue'),
    acTargetDir: document.getElementById('acTargetDir'),
    acTargetValue: document.getElementById('acTargetValue'),
    acDownBtn: document.getElementById('acDownBtn'),
    acUpBtn: document.getElementById('acUpBtn'),
    acPowerBtn: document.getElementById('acPowerBtn'),
    roomTempRow: document.getElementById('roomTempRow'),

    co2QualityPill: document.getElementById('co2QualityPill'),
    co2List: document.getElementById('co2List'),

    dehCard: document.getElementById('dehCard'),
    dehStatusPill: document.getElementById('dehStatusPill'),
    dehLockBtn: document.getElementById('dehLockBtn'),
    dehLockLabel: document.getElementById('dehLockLabel'),
    dehBucketAlert: document.getElementById('dehBucketAlert'),
    dehActualAh: document.getElementById('dehActualAh'),
    dehActualRh: document.getElementById('dehActualRh'),
    dehSetValue: document.getElementById('dehSetValue'),
    dehTargetDir: document.getElementById('dehTargetDir'),
    dehTargetValue: document.getElementById('dehTargetValue'),
    dehPowerSub: document.getElementById('dehPowerSub'),
    dehPowerValue: document.getElementById('dehPowerValue'),
    dehDownBtn: document.getElementById('dehDownBtn'),
    dehUpBtn: document.getElementById('dehUpBtn'),
    dehPowerBtn: document.getElementById('dehPowerBtn'),
    fanPowerBtn: document.getElementById('fanPowerBtn'),

    lockModal: document.getElementById('lockModal'),
    lockModalTitle: document.getElementById('lockModalTitle'),
    lockUnlockBtn: document.getElementById('lockUnlockBtn'),
    lockCancelBtn: document.getElementById('lockCancelBtn'),

    screensaverOverlay: document.getElementById('screensaverOverlay'),
    ssWidget: document.getElementById('ssWidget'),
    ssTemp: document.getElementById('ssTemp'),
    ssAirDot: document.getElementById('ssAirDot'),
    toast: document.getElementById('toast')
  };

  function cToF(c) {
    return c * 9.0 / 5.0 + 32.0;
  }

  function fToC(f) {
    return Math.round(((f - 32.0) * 5.0 / 9.0) * 100) / 100;
  }

  function formatTemp(celsius, decimals = 1) {
    if (celsius == null) return '--';
    const val = state.useFahrenheit ? cToF(celsius) : celsius;
    return val.toFixed(decimals);
  }

  function tempUnit() {
    return state.useFahrenheit ? '°F' : '°C';
  }

  function formatDuration(seconds) {
    if (seconds == null || seconds <= 0) return '';
    const mins = Math.ceil(seconds / 60);
    if (mins < 60) return `${mins}m`;
    const h = Math.floor(mins / 60);
    const m = mins % 60;
    return m > 0 ? `${h}h ${m}m` : `${h}h`;
  }

  function showToast(msg) {
    el.toast.textContent = msg;
    el.toast.classList.remove('hidden');
    clearTimeout(showToast._t);
    showToast._t = setTimeout(() => el.toast.classList.add('hidden'), 2400);
  }

  function updateClock() {
    const now = new Date();
    el.clockTime.textContent = now.toLocaleTimeString([], { hour: 'numeric', minute: '2-digit' });
    el.clockDate.textContent = now.toLocaleDateString([], { weekday: 'short', month: 'short', day: 'numeric' });
  }

  function applyPixelShift() {
    const dx = Math.floor(Math.random() * 9) - 4; // -4..+4 px
    const dy = Math.floor(Math.random() * 9) - 4;
    el.panelRoot.style.transform = `translate(${dx}px, ${dy}px)`;
  }

  function setConnStatus(ok) {
    el.connDot.className = 'conn-dot ' + (ok ? 'conn-ok' : 'conn-err');
  }

  async function fetchState() {
    clearTimeout(state.pollTimer);
    try {
      const resp = await fetch('state', { cache: 'no-store' });
      if (!resp.ok) throw new Error(`HTTP ${resp.status}`);
      state.data = await resp.json();
      state.backoffMs = POLL_MS;
      setConnStatus(true);
      render();
    } catch (err) {
      setConnStatus(false);
      state.backoffMs = Math.min(state.backoffMs * 2, MAX_BACKOFF_MS);
    } finally {
      state.pollTimer = setTimeout(fetchState, state.backoffMs);
    }
  }

  async function patchAppliance(code, body) {
    try {
      const resp = await fetch(`../appliances/${encodeURIComponent(code)}?requesterId=${REQUESTER_ID}`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(body)
      });
      if (!resp.ok) throw new Error(`HTTP ${resp.status}`);
      await fetchState();
    } catch (err) {
      showToast(`Failed to update ${code}`);
    }
  }

  function adjustAcSetting(direction) {
    const ac = state.data && state.data.appliances && state.data.appliances.AC;
    if (!ac || ac.setting == null) return;

    if (state.useFahrenheit) {
      const baseC = state.pendingAcSettingC != null ? state.pendingAcSettingC : ac.setting;
      const currentF = Math.round(cToF(baseC));
      const nextF = currentF + (direction === '+' ? 1 : -1);
      const nextC = fToC(nextF);
      state.pendingAcSettingC = nextC;
      ac.setting = nextC;
      if (ac.state === 'ON' && ac.hysteresisOff != null) {
        ac.target = nextC - ac.hysteresisOff;
      } else if (ac.hysteresisOn != null) {
        ac.target = nextC + ac.hysteresisOn;
      }
      render();

      clearTimeout(state.acDebounceTimer);
      state.acDebounceTimer = setTimeout(async () => {
        const toSend = state.pendingAcSettingC;
        state.pendingAcSettingC = null;
        await patchAppliance('AC', { setting: toSend });
      }, 280);
    } else {
      scheduleFahrenheitRevert();
      patchAppliance('AC', { setting: direction });
    }
  }

  function scheduleFahrenheitRevert() {
    clearTimeout(state.unitRevertTimer);
    if (!state.useFahrenheit) {
      state.unitRevertTimer = setTimeout(() => {
        state.useFahrenheit = true;
        state.unitRevertTimer = null;
        render();
      }, CELSIUS_REVERT_MS);
    }
  }

  function render() {
    const d = state.data;
    if (!d) return;

    el.unitToggleBtn.textContent = tempUnit();

    // Outdoor badge: OUT 24.3°C · 80% (18mg/m³)
    if (d.outdoor && d.outdoor.temp != null) {
      const cStr = d.outdoor.temp.toFixed(1);
      let humPart = '';
      if (d.outdoor.rh != null) {
        humPart = ` · ${Math.round(d.outdoor.rh)}%`;
        if (d.outdoor.ah != null) {
          humPart += ` (${Math.round(d.outdoor.ah)}mg/m³)`;
        }
      } else if (d.outdoor.ah != null) {
        humPart = ` · ${Math.round(d.outdoor.ah)}mg/m³`;
      }
      el.outdoorBadge.textContent = `OUT ${cStr}°C${humPart}`;
      el.outdoorBadge.classList.remove('hidden');
    } else {
      el.outdoorBadge.classList.add('hidden');
    }

    // AC card
    const ac = d.appliances && d.appliances.AC;
    if (ac) {
      const isOn = ac.state === 'ON';
      el.acCard.classList.toggle('state-on', isOn);
      el.acActualValue.textContent = formatTemp(ac.actual, 1);
      el.acActualUnit.textContent = tempUnit();
      el.acSetValue.textContent = ac.setting != null
        ? `${formatTemp(ac.setting, state.useFahrenheit ? 0 : 2)}${tempUnit()}`
        : '--';
      el.acTargetDir.textContent = isOn ? 'OFF AT' : 'ON AT';
      el.acTargetValue.textContent = ac.target != null ? `${formatTemp(ac.target, 1)}${tempUnit()}` : '--';

      el.acStatusPill.textContent = isOn ? 'COOLING' : 'IDLE';
      el.acStatusPill.className = 'status-pill ' + (isOn ? 'status-cooling' : 'status-idle');

      el.acPowerBtn.textContent = isOn ? 'AC ON' : 'AC OFF';
      el.acPowerBtn.className = 'power-btn' + (isOn ? ' is-on-ac' : '');

      renderLockButton(el.acLockBtn, el.acLockLabel, ac);
    }

    // Room mini temperatures
    const rooms = d.rooms || [];
    el.roomTempRow.innerHTML = rooms.map(r => `
      <div class="room-mini${r.stale ? ' stale' : ''}">
        <span class="room-mini-name">${escapeHtml(r.label)}</span>
        <span class="room-mini-val">${formatTemp(r.temp, 1)}°</span>
      </div>
    `).join('');

    // CO2 card
    renderCo2(rooms);
    renderScreensaverData();

    // DEH + FAN card
    const deh = d.appliances && d.appliances.DEH;
    if (deh) {
      const isOn = deh.state === 'ON';
      el.dehCard.classList.toggle('state-on', isOn);
      el.dehCard.classList.toggle('alert-active', Boolean(d.dehBucketFullSuspected));
      el.dehBucketAlert.classList.toggle('hidden', !d.dehBucketFullSuspected);

      el.dehActualRh.textContent = deh.actualRh != null ? `${Math.round(deh.actualRh)}` : '--';
      el.dehActualAh.textContent = deh.actual != null ? `${deh.actual.toFixed(1)} mg/m³` : '--.- mg/m³';
      el.dehSetValue.textContent = deh.setting != null ? deh.setting.toFixed(2) : '--';
      el.dehTargetDir.textContent = isOn ? 'OFF' : 'ON';
      el.dehTargetValue.textContent = deh.target != null ? deh.target.toFixed(2) : '--';

      if (d.dehPowerWatts != null) {
        el.dehPowerValue.textContent = `${Math.round(d.dehPowerWatts)}W`;
        el.dehPowerSub.classList.remove('hidden');
      } else {
        el.dehPowerSub.classList.add('hidden');
      }

      el.dehStatusPill.textContent = isOn ? 'RUNNING' : 'OFF';
      el.dehStatusPill.className = 'status-pill ' + (isOn ? 'status-good' : 'status-idle');

      el.dehPowerBtn.textContent = isOn ? 'DEH ON' : 'DEH OFF';
      el.dehPowerBtn.className = 'power-btn power-btn-sm' + (isOn ? ' is-on-deh' : '');

      renderLockButton(el.dehLockBtn, el.dehLockLabel, deh);
    }

    const fan = d.appliances && d.appliances.FAN;
    if (fan) {
      const isOn = fan.state === 'ON';
      el.fanPowerBtn.textContent = isOn ? 'FAN ON' : 'FAN OFF';
      el.fanPowerBtn.className = 'power-btn power-btn-sm power-btn-fan' + (isOn ? ' is-on-fan' : '');
      el.fanPowerBtn.classList.remove('hidden');
    } else {
      el.fanPowerBtn.classList.add('hidden');
    }
  }

  function renderLockButton(btn, label, appliance) {
    if (appliance.locked) {
      const rem = formatDuration(appliance.lockedRemainingSeconds);
      label.textContent = rem ? `Locked ${rem}` : 'Locked';
      btn.classList.add('locked');
    } else {
      label.textContent = 'Unlocked';
      btn.classList.remove('locked');
    }
  }

  function co2Level(ppm) {
    if (ppm == null) return { cls: 'co2-good', bar: 'co2-bar-good', pill: 'status-idle', air: null, label: '--' };
    if (ppm < 800) return { cls: 'co2-good', bar: 'co2-bar-good', pill: 'status-good', air: 'air-good', label: 'GOOD' };
    if (ppm <= 1200) return { cls: 'co2-fair', bar: 'co2-bar-fair', pill: 'status-fair', air: 'air-fair', label: 'MODERATE' };
    if (ppm <= 1600) return { cls: 'co2-poor', bar: 'co2-bar-poor', pill: 'status-poor', air: 'air-poor', label: 'VENTILATE' };
    return { cls: 'co2-severe', bar: 'co2-bar-severe', pill: 'status-severe', air: 'air-severe', label: 'SEVERE' };
  }

  function renderCo2(rooms) {
    const withCo2 = rooms.filter(r => r.co2 != null);
    if (withCo2.length === 0) {
      el.co2QualityPill.textContent = '--';
      el.co2QualityPill.className = 'status-pill status-idle';
      el.co2List.innerHTML = '<div class="co2-empty">No recent CO₂ readings</div>';
      return;
    }

    const maxPpm = Math.max(...withCo2.map(r => r.co2));
    const overall = co2Level(maxPpm);
    el.co2QualityPill.textContent = overall.label;
    el.co2QualityPill.className = 'status-pill ' + overall.pill;

    el.co2List.innerHTML = withCo2.map(r => {
      const lvl = co2Level(r.co2);
      const pct = Math.max(4, Math.min(100, ((r.co2 - 400) / 1500) * 100));
      return `
        <div class="co2-row${r.co2Stale ? ' stale' : ''}">
          <div class="co2-row-top">
            <span class="co2-room-name">${escapeHtml(r.label)}</span>
            <span class="co2-value-group">
              <span class="co2-value ${lvl.cls}">${Math.round(r.co2)}</span>
              <span class="co2-unit">ppm</span>
            </span>
          </div>
          <div class="co2-bar-track">
            <div class="co2-bar-fill ${lvl.bar}" style="width:${pct.toFixed(1)}%"></div>
          </div>
        </div>
      `;
    }).join('');
  }

  function openLockModal(code) {
    const app = state.data && state.data.appliances && state.data.appliances[code];
    if (!app) return;
    state.lockTargetCode = code;
    el.lockModalTitle.textContent = `${code} Lock`;
    el.lockUnlockBtn.classList.toggle('hidden', !app.locked);
    el.lockModal.classList.remove('hidden');
  }

  function closeLockModal() {
    state.lockTargetCode = null;
    el.lockModal.classList.add('hidden');
  }

  function formatUtcYyyyMmDdHhMm(date) {
    const pad = n => String(n).padStart(2, '0');
    return `${date.getUTCFullYear()}${pad(date.getUTCMonth() + 1)}${pad(date.getUTCDate())}-${pad(date.getUTCHours())}${pad(date.getUTCMinutes())}`;
  }

  function escapeHtml(str) {
    return String(str)
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;');
  }

  function buildGrafanaPanelUrl(panelId, range, cacheBust) {
    const host = window.location.hostname || '192.168.0.201';
    const params = new URLSearchParams({
      orgId: '1',
      panelId: String(panelId),
      from: `now-${range}`,
      to: 'now',
      refresh: '30s',
      theme: 'dark',
      '__feature.dashboardSceneSolo': 'true'
    });
    if (cacheBust) {
      params.set('_t', String(cacheBust));
    }
    return `http://${host}:${GRAFANA_PORT}${GRAFANA_DASHBOARD_PATH}?${params.toString()}`;
  }

  function syncChartButtons() {
    document.querySelectorAll('[data-chart-mode]').forEach(btn => {
      btn.classList.toggle('active', btn.getAttribute('data-chart-mode') === state.chartMode);
    });
    document.querySelectorAll('[data-chart-range]').forEach(btn => {
      btn.classList.toggle('active', btn.getAttribute('data-chart-range') === state.chartRange);
    });
  }

  function renderCharts(forceReload = false) {
    syncChartButtons();
    if (state.activeTab !== 'charts') {
      el.chartsGrid.innerHTML = '';
      return;
    }
    const panelIds = state.chartMode === 'all' ? [1, 2, 3] : [Number(state.chartMode)];
    el.chartsGrid.classList.toggle('single', panelIds.length === 1);
    const bust = forceReload ? Date.now() : 0;
    el.chartsGrid.innerHTML = panelIds.map(pid => `
      <div class="chart-frame-wrap">
        <iframe class="chart-frame" src="${escapeHtml(buildGrafanaPanelUrl(pid, state.chartRange, bust))}" loading="eager" referrerpolicy="no-referrer"></iframe>
      </div>
    `).join('');
  }

  function setActiveTab(tab) {
    state.activeTab = tab;
    const isCharts = tab === 'charts';
    el.tabControlsBtn.classList.toggle('active', !isCharts);
    el.tabControlsBtn.setAttribute('aria-selected', String(!isCharts));
    el.tabChartsBtn.classList.toggle('active', isCharts);
    el.tabChartsBtn.setAttribute('aria-selected', String(isCharts));
    el.controlsView.classList.toggle('hidden', isCharts);
    el.chartsView.classList.toggle('hidden', !isCharts);
    renderCharts();
  }

  function applyUiBrightness(level) {
    const clamped = Math.max(0.05, Math.min(1.0, Number(level) || 0.72));
    state.uiBrightness = clamped;
    const filterVal = `brightness(${clamped.toFixed(2)})`;
    el.panelRoot.style.filter = filterVal;
    el.screensaverOverlay.style.filter = filterVal;
  }

  function renderScreensaverData() {
    const d = state.data;
    if (!d) return;
    const ac = d.appliances && d.appliances.AC;
    if (ac && ac.actual != null) {
      el.ssTemp.textContent = cToF(ac.actual).toFixed(1);
    } else {
      el.ssTemp.textContent = '--.-';
    }

    const withCo2 = (d.rooms || []).filter(r => r.co2 != null);
    el.ssAirDot.className = 'ss-air-dot';
    if (withCo2.length > 0) {
      const maxPpm = Math.max(...withCo2.map(r => r.co2));
      const lvl = co2Level(maxPpm);
      if (lvl.air) {
        el.ssAirDot.classList.add(lvl.air);
      }
    }
  }

  function positionScreensaverWidget(instant = false) {
    const pad = 24;
    const vw = window.innerWidth;
    const vh = window.innerHeight;
    const ww = el.ssWidget.offsetWidth || Math.round(vw * 0.45);
    const wh = el.ssWidget.offsetHeight || Math.round(vh * 0.45);
    const maxX = Math.max(pad, vw - ww - pad);
    const maxY = Math.max(pad, vh - wh - pad);

    let nextX = pad + Math.random() * Math.max(0, maxX - pad);
    let nextY = pad + Math.random() * Math.max(0, maxY - pad);
    // Try to pick a meaningfully different spot from the previous position
    if (state.ssPos.x != null) {
      for (let i = 0; i < 6; i++) {
        const cx = pad + Math.random() * Math.max(0, maxX - pad);
        const cy = pad + Math.random() * Math.max(0, maxY - pad);
        const dist = Math.hypot(cx - state.ssPos.x, cy - state.ssPos.y);
        if (dist > Math.min(vw, vh) * 0.25) {
          nextX = cx;
          nextY = cy;
          break;
        }
      }
    }
    state.ssPos = { x: nextX, y: nextY };

    if (instant) {
      el.ssWidget.style.left = `${Math.round(nextX)}px`;
      el.ssWidget.style.top = `${Math.round(nextY)}px`;
      el.ssWidget.classList.remove('fading');
      return;
    }

    el.ssWidget.classList.add('fading');
    setTimeout(() => {
      if (!state.screensaverActive) return;
      el.ssWidget.style.left = `${Math.round(nextX)}px`;
      el.ssWidget.style.top = `${Math.round(nextY)}px`;
      el.ssWidget.classList.remove('fading');
    }, 450);
  }

  function setScreensaver(active) {
    if (state.screensaverActive === active) return;
    state.screensaverActive = active;
    clearInterval(state.screensaverMoveTimer);
    state.screensaverMoveTimer = null;

    if (active) {
      closeLockModal();
      if (state.activeTab !== 'controls') {
        setActiveTab('controls');
      }
      renderScreensaverData();
      el.screensaverOverlay.classList.remove('hidden');
      requestAnimationFrame(() => positionScreensaverWidget(true));
      state.screensaverMoveTimer = setInterval(() => positionScreensaverWidget(false), SCREENSAVER_MOVE_MS);
    } else {
      el.screensaverOverlay.classList.add('hidden');
    }
  }

  async function pollUiBrightness() {
    try {
      const host = window.location.hostname || '192.168.0.201';
      const resp = await fetch(`http://${host}:${NODE_RED_PORT}/api/panel/brightness`, { cache: 'no-store' });
      if (resp.ok) {
        const b = await resp.json();
        if (typeof b.activeUiBrightness === 'number') {
          state.activeUiBrightness = b.activeUiBrightness;
        }
        const wakeHold = Date.now() < state.localWakeUntil;
        const shouldShowScreensaver = Boolean(b.screensaver) && !wakeHold;
        setScreensaver(shouldShowScreensaver);
        // Normal lux-matched brightness on both active UI and OLED ambient screensaver
        applyUiBrightness(state.activeUiBrightness);
      }
    } catch (_) {
      // Keep current brightness on transient network hiccup
    } finally {
      setTimeout(pollUiBrightness, BRIGHTNESS_POLL_MS);
    }
  }

  function notifyTouchWake(force = false) {
    const now = Date.now();
    // Instant local wake while Node-RED syncs the 60s hold
    state.localWakeUntil = now + 3500;
    setScreensaver(false);
    applyUiBrightness(state.activeUiBrightness);

    if (!force && now - state.lastWakeSentAt < WAKE_THROTTLE_MS) {
      return;
    }
    state.lastWakeSentAt = now;
    const host = window.location.hostname || '192.168.0.201';
    fetch(`http://${host}:${NODE_RED_PORT}/api/panel/wake`, {
      method: 'POST',
      mode: 'no-cors'
    }).catch(() => {});
  }

  // Event Listeners
  el.screensaverOverlay.addEventListener('pointerdown', e => {
    e.preventDefault();
    e.stopPropagation();
    notifyTouchWake(true);
  });
  document.addEventListener('pointerdown', () => notifyTouchWake(false), { passive: true });
  window.addEventListener('resize', () => {
    if (state.screensaverActive) {
      positionScreensaverWidget(true);
    }
  });
  el.tabControlsBtn.addEventListener('click', () => setActiveTab('controls'));
  el.tabChartsBtn.addEventListener('click', () => setActiveTab('charts'));

  document.querySelectorAll('[data-chart-mode]').forEach(btn => {
    btn.addEventListener('click', () => {
      state.chartMode = btn.getAttribute('data-chart-mode');
      localStorage.setItem('panel.chartMode', state.chartMode);
      renderCharts();
    });
  });

  document.querySelectorAll('[data-chart-range]').forEach(btn => {
    btn.addEventListener('click', () => {
      state.chartRange = btn.getAttribute('data-chart-range');
      localStorage.setItem('panel.chartRange', state.chartRange);
      renderCharts();
    });
  });

  el.chartsRefreshBtn.addEventListener('click', () => renderCharts(true));

  el.unitToggleBtn.addEventListener('click', () => {
    state.useFahrenheit = !state.useFahrenheit;
    scheduleFahrenheitRevert();
    render();
  });

  el.fsBtn.addEventListener('click', () => {
    if (!document.fullscreenElement) {
      document.documentElement.requestFullscreen?.().catch(() => {});
    } else {
      document.exitFullscreen?.().catch(() => {});
    }
  });

  el.acDownBtn.addEventListener('click', () => adjustAcSetting('-'));
  el.acUpBtn.addEventListener('click', () => adjustAcSetting('+'));
  el.acPowerBtn.addEventListener('click', () => {
    const ac = state.data?.appliances?.AC;
    if (!ac) return;
    patchAppliance('AC', { state: ac.state === 'ON' ? 'OFF' : 'ON' });
  });
  el.acLockBtn.addEventListener('click', () => openLockModal('AC'));

  el.dehDownBtn.addEventListener('click', () => patchAppliance('DEH', { setting: '-' }));
  el.dehUpBtn.addEventListener('click', () => patchAppliance('DEH', { setting: '+' }));
  el.dehPowerBtn.addEventListener('click', () => {
    const deh = state.data?.appliances?.DEH;
    if (!deh) return;
    patchAppliance('DEH', { state: deh.state === 'ON' ? 'OFF' : 'ON' });
  });
  el.dehLockBtn.addEventListener('click', () => openLockModal('DEH'));

  el.fanPowerBtn.addEventListener('click', () => {
    const fan = state.data?.appliances?.FAN;
    if (!fan) return;
    patchAppliance('FAN', { state: fan.state === 'ON' ? 'OFF' : 'ON' });
  });

  el.lockCancelBtn.addEventListener('click', closeLockModal);
  el.lockModal.addEventListener('click', e => {
    if (e.target === el.lockModal) closeLockModal();
  });

  el.lockUnlockBtn.addEventListener('click', async () => {
    const code = state.lockTargetCode;
    closeLockModal();
    if (!code) return;
    await patchAppliance(code, { locked: false, lockedUntil: 'null' });
    showToast(`${code} unlocked`);
  });

  document.querySelectorAll('[data-lock-mins]').forEach(btn => {
    btn.addEventListener('click', async () => {
      const code = state.lockTargetCode;
      const val = btn.getAttribute('data-lock-mins');
      closeLockModal();
      if (!code) return;
      if (val === 'forever') {
        await patchAppliance(code, { locked: true, lockedUntil: 'null' });
        showToast(`${code} locked`);
      } else {
        const mins = parseInt(val, 10);
        const until = new Date(Date.now() + mins * 60 * 1000);
        // Clear any existing timed lock first so duration is relative to now
        await patchAppliance(code, { locked: true, lockedUntil: 'null' });
        await patchAppliance(code, { locked: true, lockedUntil: formatUtcYyyyMmDdHhMm(until) });
        showToast(`${code} locked for ${mins}m`);
      }
    });
  });

  // Init
  updateClock();
  setInterval(updateClock, 15000);
  setInterval(applyPixelShift, PIXEL_SHIFT_MS);
  fetchState();
  pollUiBrightness();
})();
