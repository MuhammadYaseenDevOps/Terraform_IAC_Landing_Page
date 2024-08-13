  #!/bin/bash
  set -e
  git clone https://github.com/MuhammadYaseenDevOps/Jenkinks_Pipeline_Landing_Page.git
  cd Jenkinks_Pipeline_Landing_Page
  npm install --force
  docker build -t ensmuhammadyaseen/landing-page-image .
  docker push ensmuhammadyaseen/landing-page-image
