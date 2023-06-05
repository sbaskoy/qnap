
const fs = require("fs");


setInterval(() => {
    var time = new Date().getTime();
    const pathName = `C:/Users/GaniOtomasyon_005/Desktop/QnapTest/${time}.jpg`;
    var data = `C:/Users/GaniOtomasyon_005/Desktop/copy.jpg`;
    fs.copyFile(data, pathName, fs.constants.COPYFILE_EXCL, (err) => {

    })
}, 1000)
