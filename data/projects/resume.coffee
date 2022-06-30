module.exports =
({ byCommaSpace, prevWithChanges, job }) ->
  fs     = require 'fs'
  moment = require 'moment'

  #generated: moment()
  #updated:   moment fs.statSync(__filename).mtime

  contact:
    name: "Robert de Forest"
    addr:
      street: "830 Holt Ave"
      city:   "Holtville"
      state:  "CA"
      zip:    "92250"
    phone: "+1 206 909 5590"
    email: "robert@defore.st"

  intro: '''
      Idealist seeks real-world experiences by which to claw ever closer to a
      world in which humans collaboratively refine rather than re-invent
      wheels, to the benefit of all.
    '''

  keywords:
    Modes:        byCommaSpace "Communicative, Collaborative, Cooperative, Curious"
    Languages:    byCommaSpace "CoffeeScript, JavaScript, Bash, C"
    Technologies: byCommaSpace "GNU/Linux, NodeJS, TCP/IP, AWS"

  positions: [
    job
      company: "Amazon.com"
      group: "AWS Perimeter Protection"
      title: "System Engineer II"
      from: "2015", to: "2018"

      summary: '''
      '''

      delivered: [
        "Co-founded the DDoS Response Team"
        "Built DDoS detection stack in four regions"
        "Partially automated builds, reducing effort by factor of three"
        "Covered daytime on call to guarantee timely delivery of a new product"
      ]

    job
      group: "Payments System Operations"
      from: "2012", to: "2015"

      summary: '''
      '''

      delivered: [
        "Supported Mobile Payments project", [
          "Bake-off and recommendation for DUKPT Hardware Security Modules"
          "Provided operations support and consultation to development teams"
          "Worked with third-party developer to deploy their product on AWS"
        ]
        "Supported AS2 payment processor partner communication system", [
          "Trained teammates on how the system works"
          "Obtained and renewed platform security certification"
        ]
        "Regular on-call duties of Payments SysOps", [
          "Troubleshoot payment processor communication problems"
          "Support and advise internal development teams"
        ]
        "Co-authored six-pager for moving Payments into AWS"
      ]

    job
      company: "Fred Hutch Cancer Research Center"
      group: "SCHARP.org"
      title: "DataFax Administrator"
      from: "2010", to: "2012"

      summary: '''
      '''

      delivered: [
        "Performed a major software upgrade", [
          "Refactored code defining clinical trial forms"
          "Adapted form code to take new security model into account"
        ]
        "Corrected and back-filled data reporting automation"
        "Supported in-house developers of systems extending DataFax"
        "Recovered from infrastructure issue which caused data corruption"
      ]

    job
      company: "The Walt Disney Internet Group"
      group: "Three different teams"
      title: "SysOps Specialist III"
      from: "May 2002", to: "May 2010"

      summary: '''
      '''

      delivered: [
        "Supported engineers and content producers of Disney's web properties"
        "Assisted in migration from internal Java servlet engines to Tomcat"
        "Assisted in launches of the Pirates of the Caribbean online game"
        "Wrote 'How To Be Perfect' document about data center change control"
        "Installed cabling and servers in newly expanded data center"
        "Supported internally developed email marketing system"
        "Re-architected system to reduce cost and increase availability"
      ]

    job
      company: "Three small companies"
      group:   "Santa Cruz, CA"
      title:   "Tech lead, sysadmin, etc."
      from:    "1996", to: "2002"

      summary: '''
      '''

      delivered: [
        "Desktop/server/network/hardware operations for", [
          "Got.net, an ISP with 2500 dial-up and web hosting customers"
          "Coast Commercial Bank with six branches"
          "Tapestry.net, a dot-com startup with 60 employees"
        ]
      ]

  ]
