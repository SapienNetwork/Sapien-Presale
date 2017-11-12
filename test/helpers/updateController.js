module.exports = async function(Controller, controllerAddress) {
    await Controller.changeController(controllerAddress);
};