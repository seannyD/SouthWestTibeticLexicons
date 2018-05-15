
Concepticon data download
=========================

Data of Concepticon is published under the following license:
http://creativecommons.org/licenses/by/4.0/

It should be cited as

List, Johann Mattis & Cysouw, Michael & Greenhill, Simon & Forkel, Robert (eds.) 2018.
Concepticon.
Jena: Max Planck Institute for the Science of Human History.
(Available online at http://concepticon.clld.org, Accessed on 2018-03-07.)


Description
-----------

The file conceptset.json contains information about concept sets labels and alternative
labels used in concept lists in the following format:

```
{
    "conceptset_labels": {
        "run": [
            "1519",
            "RUN"
        ],
        ...
    }
    "alternative_labels": {
        "to run": [
            "1519",
            "RUN"
        ],
        ...
    }
}
```

The `conceptset_labels` dictionary maps the lowercased english unique concept set label
to pairs `(CONCEPTSET_ID, CONCEPTSET_LABEL)`, while
the `alternative_labels` dictionary maps the lowercased english labels encountered in
concept lists to pairs `(CONCEPTSET_ID, CONCEPTSET_LABEL)`.
