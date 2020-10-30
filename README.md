# Installation assets for CP4MCM 2.1

**Note:** This project is provided **AS-IS**. Support will be provided as possible via git issues.

## Overview:

This project is designed to provide an automated way to install the Cloud Pak for Multi Cloud Management v 2.1.

### Scope:

Single replica (Non-HA) Configuration

This automation currently provides the following installation functionality:

- MCM Core
- MCM Monitoring Module
- MCM Infrastructure Management Module
- CloudForms ([with sample LDAP](./ldap_schema.md))

In development:

- Ansible Tower
- Red Hat Advanced Cluster Management 2.0

## Usage:

There are two ways this automation can be used.
1. You can clone this repo and execute the commands locally
2. You can execute the installation from the Docker image that has been built (Beta)

### Executing locally

**Pre-reqs**
- `oc` command
- You must be authenticated to your OpenShift cluster
- `make` command
- [IBM Entitled Registry Key](https://myibm.ibm.com/products-services/containerlibrary)
- If installing RHACM, [Red Hat Pull Secret](https://cloud.redhat.com/openshift/install/pull-secret)

**Process**
1. Clone repo locally:
```
git clone git@github.com:ibm-garage-tsa/cp4mcm-installer.git
```

2. Export your entitled registy key:
```
export ENTITLED_REGISTRY_KEY="Your long key here"
```

3. Setup the storage classes in the `0_setup_env.sh file`:

- If you are using ROKS you can just accept the defaults
- If you are using OpenShift Container Storage you can accept the defaults
- If you are using some other storage solution you will need to customize the storage classes
  
4. Make sure you are in the base project folder and execute the install using the Makefile

- If you want to install the core Cloud Pak for Multi Cloud Management with out any additonal modules execute the `make mcmcore` command

- After you have installed the core you can enable the Monitoring Module by running the `make mcmenablemonitoring`.

- If you want to add the Infrastructure Management module on top of the core you can run `make mcmenableim`

- If you want to install all of the components you can run `make all`

- If you want to install RHACM, first you need to export the variable `RED_HAT_PULL_SECRET_PATH` with the path to your Red Hat pull secret (get it from [Red Hat here](https://cloud.redhat.com/openshift/install/pull-secret)). After that you can run `make rhacm`.

- If you want to uninstall RHACM you can run `./rhacm/99-rhacm-uninstall.sh`(Need to change permissions to 755)

### Containerized execution

Coming soon

## Known limitations:

- Does not work on ROKS with VPC
- Supports online installation only
- Supports OpenShift 4.x
- Installing RHACM should be done before MCM Core and you need to manually change the flag `mcmCoreDisabled` to **true** before installing MCM Core.