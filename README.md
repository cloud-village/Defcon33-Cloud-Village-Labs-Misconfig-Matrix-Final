![CloudVillage](https://forum.defcon.org/filedata/fetch?id=248684&d=1710292743)

# The Misconfig Matrix: From Chaos to Control

The following repository contains all the material for our cloud village lab at Defcon on `August 10th 2025` held between `10:30 - 11:30 AM`.  

## Workshop Outline

Participants will automate scans against multiple misconfigured environments and learn to interpret findings in context using a set of open-source CSPM tools across simulated multi-cloud infrastructure.

The lab culminates in comparing tools using a **Pugh Matrix**. Attendees will compare tools based on **coverage, usability, integration**, and **accuracy**, equipping them with a repeatable evaluation framework tailored to organizational maturity, size, and resource constraints.

---

## Pre-setup Phase

To take full advantage of this lab participants can clone this Github repository. A Github account can be created by signing up at github.com, there are a lot of extra benefits if participants have access to a .edu account, more inforamtion can be found at https://education.github.com/pack.

AWS Cli : https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html

Docker Compose: Installation steps

```
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

### Minimum Requirements:

Machine with access to a Cli perferabily linux based systems or git bash for Windows users. https://git-scm.com/downloads.

We can also run the lab in a free google cloud account which can be accessed by visiting : [console.google.com.](https://console.cloud.google.com/) 

After signing in users can access the cloud shell, clone the github repository and start running the commands as per the readme files in under each tool.

### Nice to have:

Docker/Podman/Container tools. https://www.docker.com/products/docker-desktop/, https://podman.io/   

## Part 1 : Overview of CSPM tools and discussion of common misconfiguarations across multiple clouds

In this lab we would be deploying and comparing various open source CSPM tools as given below:

### 1. Scout Suite:

Scout Suite is an open source multi-cloud security-auditing tool, which enables security posture assessment of cloud environments. Using the APIs exposed by cloud providers, Scout Suite gathers configuration data for manual inspection and highlights risk areas. Rather than going through dozens of pages on the web consoles, Scout Suite presents a clear view of the attack surface automatically.

Scout Suite was designed by security consultants/auditors. It is meant to provide a point-in-time security-oriented view of the cloud account it was run in. Once the data has been gathered, all usage may be performed offline.

Link: https://github.com/nccgroup/ScoutSuite/tree/master
   
### 2. Cloud Custodian:

Cloud Custodian, also known as c7n, is a rules engine for managing public cloud accounts and resources. It allows users to define policies to enable a well managed cloud infrastructure, that's both secure and cost optimized. It consolidates many of the adhoc scripts organizations have into a lightweight and flexible tool, with unified metrics and reporting.

Custodian can be used to manage AWS, Azure, and GCP environments by ensuring real time compliance to security policies (like encryption and access requirements), tag policies, and cost management via garbage collection of unused resources and off-hours resource management.

Link: https://github.com/cloud-custodian/cloud-custodian/
   
### 3. CloudMapper:

CloudMapper helps you analyze your Amazon Web Services (AWS) environments. The original purpose was to generate network diagrams and display them in your browser (functionality no longer maintained). It now contains much more functionality, including auditing for security issues.

Link: https://github.com/duo-labs/cloudmapper 
   
### 4. Cartography:
   
Cartography is a Python tool that consolidates infrastructure assets and the relationships between them in an intuitive graph view powered by a Neo4j database.

Cartography aims to enable a broad set of exploration and automation scenarios. It is particularly good at exposing otherwise hidden dependency relationships between your service's assets so that you may validate assumptions about security risks.

Link: https://github.com/cartography-cncf/cartography 
   
### 5. Prowler

Prowler is an open-source security tool designed to assess and enforce security best practices across AWS, Azure, Google Cloud, and Kubernetes. It supports tasks such as security audits, incident response, continuous monitoring, system hardening, forensic readiness, and remediation processes.

Link: https://github.com/prowler-cloud/prowler
    

## Part 2 : Baseline Tool Scan 

Download the credentials from the bitly link and place them in the home directory of the repository. 

We can navigate to each tool in the repository and find the Readme along with the scan results. We have provided HTML files which can be downloaded and viewed if there are technical issues when installing scripts and tools.
Running scripts and make note of limitations / differences between each tool.

1. ScouteSuite: https://github.com/HariPranav/Misconfig-Matrix-From-Chaos-to-Control/tree/master/scoutsuite
2. Cloudcustodian: https://github.com/HariPranav/Misconfig-Matrix-From-Chaos-to-Control/tree/master/cloudcustodian
3. Cartographer: https://github.com/HariPranav/Misconfig-Matrix-From-Chaos-to-Control/tree/master/cartographer
4. Prowler: https://github.com/HariPranav/Misconfig-Matrix-From-Chaos-to-Control/tree/master/prowler


## Part 3: Pugh Matrix Evaluation


## Part 4: Questions

## 👨‍🏫 Instructors

### Hari Pranav Arun Kumar
Hari is a Security Engineer working to improve cloud, application, and runtime security. He's contributed to Cloud Village CTFs over the past two years and is passionate about tinkering, and he's a frequent hackathon participant and educator.

### Ritvik Arya
Ritvik is an Application Security Engineer with expertise in securing cloud applications, threat modeling, and secure code reviews. He's also a bug bounty hunter and works on container security. Ritvik is a contributor to **Cloud Village** CTFs and enjoys building security challenges.


#### Note
Opinions expressed are solely our own and do not express the views or opinions of my employer.