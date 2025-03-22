let players = [];

window.addEventListener('message', function(event) {
    const item = event.data;
    
    if (item.action === "openMenu") {
        players = item.players;
        document.getElementById('container').style.display = 'block';
        updatePlayerList();
    }
});

function updatePlayerList() {
    const playerList = document.getElementById('playerList');
    playerList.innerHTML = '';
    
    players.forEach(player => {
        const playerCard = document.createElement('div');
        playerCard.className = 'player-card';
        
        playerCard.innerHTML = `
            <div class="player-info">
                <h3>${player.name}</h3>
                <p>ID: ${player.source}</p>
                <p>Meslek: ${player.job.name} (Grade ${player.job.grade.level})</p>
            </div>
            <div class="player-actions">
                <input type="text" class="job-input" placeholder="Meslek" value="${player.job.name}">
                <input type="number" class="grade-input" placeholder="Grade" value="${player.job.grade.level}" min="0">
                <button class="set-job-btn" onclick="setJob(${player.source})">Meslek Değiştir</button>
                <button class="remove-job-btn" onclick="removeJob(${player.source})">Meslekten Çıkar</button>
            </div>
        `;
        
        playerList.appendChild(playerCard);
    });
}

function setJob(playerId) {
    const playerCard = document.querySelector(`.player-card:has(p:contains("ID: ${playerId}"))`);
    const jobInput = playerCard.querySelector('.job-input').value;
    const gradeInput = parseInt(playerCard.querySelector('.grade-input').value);
    
    if (!jobInput || isNaN(gradeInput)) {
        return;
    }
    
    fetch(`https://${GetParentResourceName()}/setJob`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            playerId: playerId,
            job: jobInput,
            grade: gradeInput
        })
    });
}

function removeJob(playerId) {
    fetch(`https://${GetParentResourceName()}/setJob`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            playerId: playerId,
            job: 'unemployed',
            grade: 0
        })
    });
}

function closeMenu() {
    document.getElementById('container').style.display = 'none';
    fetch(`https://${GetParentResourceName()}/closeMenu`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({})
    });
}

// ESC tuşu ile menüyü kapatma
document.addEventListener('keyup', function(event) {
    if (event.key === 'Escape') {
        closeMenu();
    }
});