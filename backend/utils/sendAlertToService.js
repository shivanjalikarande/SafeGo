async function sendAlertToService(name, address) {
    // In production, you'd use Twilio or SMS gateway
    console.log(`📢 Alert sent to ${name} at ${address}`);
}

module.exports = { sendAlertToService };