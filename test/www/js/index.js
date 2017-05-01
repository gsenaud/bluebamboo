var app = {
    // Application Constructor
    initialize: function() {
        document.addEventListener('deviceready', this.onDeviceReady.bind(this), false);
        console.log('booting...');
    },

    onDeviceReady: function() {
        console.log('device ready');
        document.body.querySelector('.connectBtn').addEventListener('touchstart',this.connectCb.bind(this));
        document.body.querySelector('.disconnectBtn').addEventListener('touchstart',this.disconnectCb.bind(this));
        document.body.querySelector('.displayBtn').addEventListener('touchstart',this.displayCb.bind(this));
        document.body.querySelector('.emvBtn').addEventListener('touchstart',this.emvCb.bind(this));
        document.body.querySelector('.msrBtn').addEventListener('touchstart',this.msrCb.bind(this));
        document.body.querySelector('.iccBtn').addEventListener('touchstart',this.iccCb.bind(this));
        document.body.querySelector('.prntBtn').addEventListener('touchstart',this.printCb.bind(this));

        this.display = document.body.querySelector('.console');
    },

    clean: function() {
        this.display.innerText = '';
    },

    connectCb: function() {
        console.log('connecting...');
        this.clean();
        var _this = this;
        bluebamboo.connect(
            function() {
                _this.connected = true;
                console.log('connect cb OK');
                document.body.classList.toggle('connected',true);
            },
            function(e) {
                _this.connected = false;
                console.error('connect error',e);
                document.body.classList.toggle('connected',false);
            }
        );
    },

    disconnectCb: function() {
        console.log('disconnecting...');
        var _this = this;
        bluebamboo.disconnect(
            function() {
                _this.connected = false;
                console.log('disconnect cb OK');
                document.body.classList.toggle('connected',false);
            }
        );
    },

    msrCb: function() {
        console.log('starting MSR...');
        this.display.innerText = 'Veuillez patienter...';
        var _this = this;
        bluebamboo.startMSR(
            function(d) {
                console.log('MSR success',d);
                _this.display.innerText = d;
            },
            function(e) {
                alert('MSR error: '+e);
                console.error('MSR error',e);
                _this.display.innerText = 'MSR error: '+e+'\nVeuillez réessayer...';
            });
    },

    iccCb: function() {
        console.log('starting ICC...');
        this.display.innerText = 'Veuillez patienter...';
        var _this = this;
        bluebamboo.startICC(
            function(d) {
                console.log('ICC success',d);
                _this.display.innerText = d;
            },
            function(e) {
                alert('ICC error: '+e);
                _this.display.innerText = 'ICC error: '+e+'\nVeuillez réessayer...';
                console.error('ICC error',e);
            });
    },

    displayCb: function() {
        console.log('starting display...');
        this.clean();
        bluebamboo.startDisplay(["Inserer", "votre carte"]);
    },

    emvCb: function() {
        console.log('starting EMV...');
        this.display.innerText = 'Veuillez patienter...';
        var _this = this;
        bluebamboo.startEMV(
            15.75, // amount
            function(d) {
                console.log('EMV success',d);
                _this.display.innerText = d;
            },
            function(e) {
                alert(e);
                console.error('EMV error',e);
                _this.display.innerText = e;
            },);
    },

    printCb: function() {
        console.log('printing ticket...');
        this.display.innerText = 'Veuillez patienter, impression en cours...';
        var _this = this;
        bluebamboo.print(
            [
                { type: "text", value: "           SHIFTEO" },
                { type: "text", value: "------------------------------" },
                { type: "text", value: "Merchant ID: " },
                { type: "text", value: "XXXXXXXXXX" },
                { type: "text", value: "Terminal ID: " },
                { type: "text", value: "XXXXXXXXXX" },
                { type: "text", value: "------------------------------" },
                { type: "text", value: "Card Number: " },
                { type: "text", value: "1234 5678 9012 3456" },
                { type: "text", value: "Type: SALE" },
                { type: "text", value: " " },
                { type: "text", value: "Receipt ID: " },
                { type: "text", value: "1234567890" },
                { type: "text", value: "Date/Time: " },
                { type: "text", value: (new Date()).toLocaleString("fr-FR") },
                { type: "text", value: "Montant de la transaction: " },
                { type: "text", value: "15,75 €" },
                { type: "text", value: "------------------------------" },
                { type: "text", value: "Au revoir et à bientôt!" }
            ],
            function() {
                console.log('print success');
                _this.display.innerText = "Votre ticket est prêt sur votre P200!";
            },
            function(e) {
                alert(e);
                console.error('print error',e);
                _this.display.innerText = e;
            });
    }
};

app.initialize();
