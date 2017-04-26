[![Build Status](https://travis-ci.org/sul-dlss/sparql_to_sw_solr.svg?branch=master)](https://travis-ci.org/sul-dlss/sparql_to_sw_solr)
[![Coverage Status](https://coveralls.io/repos/github/sul-dlss/sparql_to_sw_solr/badge.svg)](https://coveralls.io/github/sul-dlss/sparql_to_sw_solr)
[![Dependency Status](https://gemnasium.com/badges/github.com/sul-dlss/sparql_to_sw_solr.svg)](https://gemnasium.com/github.com/sul-dlss/sparql_to_sw_solr)

[![GitHub version](https://badge.fury.io/gh/sul-dlss%2Fsparql_to_sw_solr.svg)](https://badge.fury.io/gh/sul-dlss%2Fsparql_to_sw_solr)

# sparql_to_sw_solr

Perform SPARQL queries against a triplestore to get the data to create Solr documents specific to SearchWorks ... and write the Solr documents to Solr.

Additional details about Solr are documented on Consul, see 
 - https://consul.stanford.edu/pages/viewpage.action?pageId=156860714

## Development

### Installing code locally

```
bundle
```

### Running tests locally

```
rake spec
```


## Deployment

Capistrano is used for deployment.

1. On your laptop, run

    `bundle`

  to install the Ruby capistrano gems and other dependencies for deployment.

2. Set up shared directories on the remote VM:

    ```
    ssh remote-vm
    cd sparql_to_sw_solr
    mkdir shared
    mkdir shared/log
    ```

3. Deploy code to remote VM:

    `cap dev deploy`


### Running Code Remotely

Code is run as a batch process via Capistrano.
