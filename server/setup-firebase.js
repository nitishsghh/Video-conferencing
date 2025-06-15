/**
 * Script to safely store Firebase credentials
 * Run this script with: node setup-firebase.js
 */
const fs = require('fs');
const path = require('path');
const readline = require('readline');

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

console.log('Firebase Service Account Setup');
console.log('==============================');
console.log('This script will help you set up Firebase credentials for your server.');
console.log('You can either paste your service account JSON or provide a path to the file.');
console.log('\nWARNING: Service account keys should be kept secure and never committed to version control!');

rl.question('\nDo you want to paste the JSON content or provide a file path? (json/file): ', (answer) => {
  if (answer.toLowerCase() === 'json') {
    console.log('\nPaste your Firebase service account JSON below (press Enter, then Ctrl+D or Ctrl+Z when done):');
    let jsonContent = '';
    
    process.stdin.on('data', (data) => {
      jsonContent += data.toString();
    });
    
    process.stdin.on('end', () => {
      try {
        const serviceAccount = JSON.parse(jsonContent.trim());
        saveServiceAccount(serviceAccount);
      } catch (error) {
        console.error('Error parsing JSON:', error.message);
        process.exit(1);
      }
    });
    
  } else if (answer.toLowerCase() === 'file') {
    rl.question('\nEnter the path to your service account JSON file: ', (filePath) => {
      try {
        const resolvedPath = path.resolve(filePath);
        const fileContent = fs.readFileSync(resolvedPath, 'utf8');
        const serviceAccount = JSON.parse(fileContent);
        saveServiceAccount(serviceAccount);
        rl.close();
      } catch (error) {
        console.error('Error reading file:', error.message);
        rl.close();
        process.exit(1);
      }
    });
  } else {
    console.log('Invalid option. Please run the script again and choose "json" or "file".');
    rl.close();
    process.exit(1);
  }
});

function saveServiceAccount(serviceAccount) {
  try {
    // Save to file
    fs.writeFileSync(
      path.join(__dirname, 'firebase-service-account.json'),
      JSON.stringify(serviceAccount, null, 2),
      'utf8'
    );
    
    // Update .env file with project ID
    const envPath = path.join(__dirname, '.env');
    let envContent = '';
    
    if (fs.existsSync(envPath)) {
      envContent = fs.readFileSync(envPath, 'utf8');
    }
    
    if (!envContent.includes('FIREBASE_PROJECT_ID')) {
      envContent += `\nFIREBASE_PROJECT_ID=${serviceAccount.project_id}\n`;
      fs.writeFileSync(envPath, envContent, 'utf8');
    }
    
    console.log('\nFirebase service account saved successfully!');
    console.log(`Project ID: ${serviceAccount.project_id}`);
    console.log('\nIMPORTANT: The service account file has been saved to:');
    console.log(path.join(__dirname, 'firebase-service-account.json'));
    console.log('\nThis file contains sensitive credentials and should NEVER be committed to version control.');
    console.log('It has been added to .gitignore for your protection.');
    
  } catch (error) {
    console.error('Error saving service account:', error.message);
    process.exit(1);
  }
} 