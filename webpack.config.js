var path = require('path');

module.exports = {
    entry: "./index.cjsx",
    output: {
        path: path.join(__dirname, "public"),
        filename: "bundle.js"
    },
    module: {
        loaders: [
            { test: /\.css$/,
              loader: "style!css"
            },
            { test: /\.coffee$/,
              loader: "coffee"
            },
            {
              test: /\.cjsx$/,
              loaders: ["coffee", "cjsx"]
            }
        ]
    }
};
