#!/usr/bin/node

const fs = require("fs").promises;
const path = require("path");
const { argv } = require("process");

async function deleteFilesInDirectory(
  directoryPath,
  filePredicate,
  deleteFile
) {
  const files = await fs.readdir(directoryPath);
  await Promise.all(files.map(async (fileName) => {
    const fullPath = path.join(directoryPath, fileName);
    const fileStats = await fs.lstat(fullPath);
    if(fullPath.includes('node_modules')) {
      return Promise.resolve();
    }

    if (fileStats.isDirectory()) {
      await deleteFilesInDirectory(fullPath, filePredicate, deleteFile);
    } else if (filePredicate(fileName, files)) {
      await deleteFile(fullPath);
    }
  }));
}

function shouldDeleteFile(fileName, allFiles) {
  const split = fileName.split(".");
  const extension = split.pop();
  const fileNameWithoutExtension = split.join(".");

  return (
    extension === "js" && allFiles.includes(`${fileNameWithoutExtension}.ts`)
  );
}

async function deleteFile(fullPath) {
  return fs.unlink(fullPath).then(() => {
    console.log(fullPath, "deleted.");
  });
}

function run() {
  const deleteFilesIn = async (directoryPath) =>
    deleteFilesInDirectory(directoryPath, shouldDeleteFile, deleteFile);

  const relativePathFromArgs = argv[2];

  if (typeof relativePathFromArgs === "string") {
    const finalPath = path.resolve(process.cwd(), relativePathFromArgs);
    console.log(`Removing files from given path ${finalPath} ...`)
    return deleteFilesIn(finalPath);
  } else {
    return Promise.reject(new Error("path is missing"));
  }
}

run()
  .then(() => {
    console.log("Done!");
  })
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
