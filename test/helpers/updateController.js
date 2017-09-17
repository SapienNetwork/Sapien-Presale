module.exports = async function(SPN, controllerAddress) {
    await SPN.changeController(controllerAddress);
};