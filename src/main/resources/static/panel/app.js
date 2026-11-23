(() => {
  'use strict';

  const POLL_MS = 5000;
  const MAX_BACKOFF_MS = 30000;
  const PIXEL_SHIFT_MS = 5 * 60 * 1000;
  const WAKE_HOLD_MS = 45 * 1000;
  const REQUESTER_ID = 'wall-panel';

  const state = {
    data: null,
    useFahrenheit: localStorage.getItem('panel.useFahrenheit') !== 'false',
    manualDim: localStorage.getItem('panel.manualDim') === 'true',
    wakeUntil: 0,
    backoffMs: POLL_MS,
    pollTimer: null,
    lockTargetCode: null,
    pendingAcSettingC: null,
    acDebounceTimer: null,
    busy: false
  };

  const el = {
    panelRoot: document.getElementById('panelRoot'),
    clockTime: document.getElementById('clockTime'),
    clockDate: document.getElementById('clockDate'),
    outdoorBadge: document.getElementById('outdoorBadge'),
    connDot: document.getElementById('connDot'),
    unitToggleBtn: document.getElementById('unitToggleBtn'),
    dimToggleBtn: document.getElementById('dimToggleBtn'),
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

    dimOverlay: document.getElementById('dimOverlay'),
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
    updateNightDim(now);
  }

  function updateNightDim(now = new Date()) {
    const hour = now.getHours();
    const isNightHours = hour >= 23 || hour < 7;
    const shouldDim = (state.manualDim || isNightHours) && Date.now() >= state.wakeUntil;
    el.dimOverlay.classList.toggle('hidden', !shouldDim);
    el.dimToggleBtn.classList.toggle('active', state.manualDim);
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
      patchAppliance('AC', { setting: direction });
    }
  }

  function render() {
    const d = state.data;
    if (!d) return;

    el.unitToggleBtn.textContent = tempUnit();

    // Outdoor badge
    if (d.outdoor && d.outdoor.temp != null) {
      const rhPart = d.outdoor.rh != null ? ` · ${Math.round(d.outdoor.rh)}%` : '';
      el.outdoorBadge.textContent = `OUT ${formatTemp(d.outdoor.temp, 0)}${tempUnit()}${rhPart}`;
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

    // DEH + FAN card
    const deh = d.appliances && d.appliances.DEH;
    if (deh) {
      const isOn = deh.state === 'ON';
      el.dehCard.classList.toggle('state-on', isOn);
      el.dehCard.classList.toggle('alert-active', Boolean(d.dehBucketFullSuspected));
      el.dehBucketAlert.classList.toggle('hidden', !d.dehBucketFullSuspected);

      el.dehActualAh.textContent = deh.actual != null ? deh.actual.toFixed(1) : '--.-';
      el.dehActualRh.textContent = deh.actualRh != null ? `${Math.round(deh.actualRh)}%` : '--%';
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
    if (ppm == null) return { cls: 'co2-good', bar: 'co2-bar-good', pill: 'status-idle', label: '--' };
    if (ppm < 800) return { cls: 'co2-good', bar: 'co2-bar-good', pill: 'status-good', label: 'GOOD' };
    if (ppm <= 1200) return { cls: 'co2-fair', bar: 'co2-bar-fair', pill: 'status-fair', label: 'MODERATE' };
    return { cls: 'co2-poor', bar: 'co2-bar-poor', pill: 'status-poor', label: 'VENTILATE' };
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
      const pct = Math.max(4, Math.min(100, ((r.co2 - 400) / 1200) * 100));
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

  // Event Listeners
  el.unitToggleBtn.addEventListener('click', () => {
    state.useFahrenheit = !state.useFahrenheit;
    localStorage.setItem('panel.useFahrenheit', String(state.useFahrenheit));
    render();
  });

  el.dimToggleBtn.addEventListener('click', () => {
    state.manualDim = !state.manualDim;
    localStorage.setItem('panel.manualDim', String(state.manualDim));
    state.wakeUntil = 0;
    updateNightDim();
  });

  el.dimOverlay.addEventListener('click', () => {
    state.wakeUntil = Date.now() + WAKE_HOLD_MS;
    updateNightDim();
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
})();
