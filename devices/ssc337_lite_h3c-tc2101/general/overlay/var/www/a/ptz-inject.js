(function() {
    'use strict';

    // Prevent duplicate injection
    if (document.getElementById('mj-ptz-inject')) return;

    // PTZ commands (Base64-encoded gpio-motors commands)
    var cmds = {
        up:    'Z3Bpby1tb3RvcnMgMCA1IDEw',
        down:  'Z3Bpby1tb3RvcnMgMCAtNSAxMA==',
        left:  'Z3Bpby1tb3RvcnMgLTUgMCAxMA==',
        right: 'Z3Bpby1tb3RvcnMgNSAwIDEw',
        stop:  'Z3Bpby1tb3RvcnMgMCAwIDA='
    };

    // Create control panel
    var pad = document.createElement('div');
    pad.id = 'mj-ptz-inject';
    pad.style.cssText = [
        'position: fixed',
        'left: 1rem',
        'bottom: 1rem',
        'z-index: 9999',
        'display: grid',
        'grid-template-columns: repeat(3, 3rem)',
        'grid-template-rows: repeat(3, 3rem)',
        'gap: 4px',
        'padding: 6px',
        'background: rgba(0,0,0,0.6)',
        'border-radius: 10px',
        'user-select: none'
    ].join(';');

    // Button style
    var btnStyle = [
        'background: rgba(255,255,255,0.15)',
        'border: 1px solid rgba(255,255,255,0.3)',
        'border-radius: 6px',
        'color: #fff',
        'font-size: 1.2rem',
        'cursor: pointer',
        'display: flex',
        'align-items: center',
        'justify-content: center',
        'transition: background 0.15s'
    ].join(';');

    // Layout: up, left, stop, right, down
    var layout = [
        { dir: 'up',    row: 1, col: 2, label: '^' },
        { dir: 'left',  row: 2, col: 1, label: '<' },
        { dir: 'stop',  row: 2, col: 2, label: 'O' },
        { dir: 'right', row: 2, col: 3, label: '>' },
        { dir: 'down',  row: 3, col: 2, label: 'v' }
    ];

    layout.forEach(function(item) {
        var btn = document.createElement('button');
        btn.type = 'button';
        btn.textContent = item.label;
        btn.dataset.dir = item.dir;
        btn.style.cssText = btnStyle;
        btn.style.gridRow = item.row;
        btn.style.gridColumn = item.col;

        // Highlight on press
        btn.addEventListener('pointerdown', function() {
            btn.style.background = 'rgba(255,255,255,0.4)';
        });
        btn.addEventListener('pointerup', function() {
            btn.style.background = 'rgba(255,255,255,0.15)';
        });
        btn.addEventListener('pointerleave', function() {
            btn.style.background = 'rgba(255,255,255,0.15)';
        });

        pad.appendChild(btn);
    });

    // Inject into page
    document.body.appendChild(pad);

    // Send command
    function fire(dir) {
        var b64 = cmds[dir];
        if (!b64) return;
        fetch('/cgi-bin/j/run.cgi?web=' + encodeURIComponent(b64), {
            credentials: 'same-origin'
        }).catch(function() {});
    }

    // Long-press continuous send
    var holdTimer = null;
    var holdDir = null;

    function startHold(dir) {
        stopHold();
        holdDir = dir;
        fire(dir);
        holdTimer = setInterval(function() {
            fire(dir);
        }, 250);
    }

    function stopHold() {
        if (holdTimer) {
            clearInterval(holdTimer);
            holdTimer = null;
        }
        // Send stop command on release (except for the stop button itself)
        if (holdDir && holdDir !== 'stop') {
            fire('stop');
        }
        holdDir = null;
    }

    // Bind events
    pad.addEventListener('pointerdown', function(e) {
        var btn = e.target.closest('button');
        if (!btn) return;
        e.preventDefault();
        try { btn.setPointerCapture(e.pointerId); } catch(err) {}
        startHold(btn.dataset.dir);
    });

    pad.addEventListener('pointerup', stopHold);
    pad.addEventListener('pointercancel', stopHold);

    window.addEventListener('blur', stopHold);
})();