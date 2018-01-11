{ byCommaSpace, prevWithChanges, job } = require '../../../lib/builder'

module.exports =
resume =
  contact:
    name: "Robert de Forest"
    addr:
      street: "1215 Seneca St #307"
      city:   "Seattle"
      state:  "WA"
      zip:    "98101"
    phone: "+1 206 909 5590"
    email: "robert@defore.st"

  intro: '''
      An idealist with majestic dreams seeks real-world experiences by which
      to claw ever closer to a world in which humans only refine wheels
      rather than re-inventing them, to the benefit of all.
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
      from: "2015", to: "Present"

      delivered: [
        "Co-founded the DDoS Response Team"
        "Built DDoS detection stack in four regions"
        "Partially automated builds, reducing effort by factor of three"
        "Covered daytime on call to facilitate team delivery of a new product on time"
      ]

    job
      group: "Payments System Operations"
      from: "2012", to: "2015"

      delivered: [
        "Supported Mobile Payments project", [
          "Executed bake-off and made recommendation for DUKPT-capable Hardware Security Modules"
          "Provided operations support and consultation to development teams"
          "Worked with third-party developer to deploy their product on AWS"
        ]
        "Supported AS/2 file delivery platform used for communication with payment processors", [
          "Trained teammates on how the AS/2 platform works"
          "Obtained and renewed application security certification for the AS/2 platform"
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

      delivered: [
        "Performed a major software upgrade", [
          "Refactored code defining clinical trial forms"
          "Adapted form code to take new security model into account"
        ]
        "Corrected and back-filled data reporting automation"
        "Supported developers maintaining in-house applications which integrate with DataFax"
        "Recovered from infrastructure issue which caused data corruption"
      ]

    job
      company: "The Walt Disney Internet Group"
      group: "Three different teams"
      title: "SysOps Specialist III"
      from: "May 2002", to: "May 2010"

      delivered: [
        "Supported engineers and content producers of the many Disney web properties such as ABC News and ESPN"
        "Assisted in migration from internally-developed Java servlet engines to Apache Tomcat"
        "Assisted in launches of the Pirates of the Caribbean and Club Penguin online games"
        "Wrote 'How To Be Perfect' documentation for reducing human error in operations"
        "Built out data center expansion after installation of power, cooling and rack cages"
        "Supported internally developed email marketing platform"
        "Re-architected platform to reduce cost and increase availability"
      ]

    job
      company: "Three small companies"
      group: "Santa Cruz, CA"
      title: "Tech lead, sysadmin, etc."
      from: "1996", to: "2002"

      delivered: [
        "Desktop/server/network/hardware operations for", [
          "Got.net, an ISP with 2500 dial-up and web hosting customers"
          "Coast Commercial Bank with six branches"
          "Tapestry.net, a dot-com startup with 60 employees"
        ]
      ]

  ]