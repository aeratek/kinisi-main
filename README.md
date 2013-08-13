

#Kinisi Data Management Network

{API Semantics - Experimental}

The core of this API experiment is the desire to build an API that doesn't make a ton of assumptions
about the underlying storage technology. That said, there are some guarantees that must be reached in 
order to build a data product with support for large sequences. 

The KDMN is designed for access from RESTful interfaces, and does not support arbirtrarily large transactions.
The core, first class objects in the KDMN are documents and sequences. Changes to documents are guaranteed
to be atomic, while multi-row updates to sequences are not. Sequences can be really large, fixed schemas, where as documents
are not fixed schema. That is to say, once the schema for a sequence is defined, all the usual costs of updating 
the schema apply (think the relational case). 

First Class Objects
- a document (platform in the prototype)
    - Core attributes:
        1. uid: universally unique identifier (fixed)
        2. name: a short, human-friendly name for the platform (changeable, non-unique, 160 character limit)
        3. created: timestamp of when the record was first created (fixed)
        3. current: enumeration of 0 {not active}, 1 {active}, 2 {reserved}, 3 {marked for deletion}
        4. description: text description (1000 character limit) 
    - Meta attributes: 
        1. meta: storage of variable schema

- a sequence (sequence in the prototype)
    - no core attributes, schema defined upon creation

- the primitives
    - integer, float, text, uuid (relation), sequences


Currently Supported Operations

- get a document, given a valid identifier
- get a subset of all documents to support paging semantics
- update on documents *
    1. create document
    2. delete document
    3. get document
    4. get page in list of all documents
    5. change request: 
        - add attribute (variable schema) and value
        - delete attribute (and its value)
        - change attribute value

- get a subset of a sequence, given a document identifier
- update on sequences *
    1. create sequence
    2. delete sequence
    3. change request:
        - append to sequence


* because networks can partition & platforms can go offline, there is no guarantee that an update will 
universally take place, or a delete will universally propagate until all partitions are healed. creates also
suffer from this problem, but unique ID generation attempts to work around this problem to avoid collisions

