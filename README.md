This repository records codebases that are in compliance with the [Standard for Public Code](https://standard.publiccode.net).
The record consists by three files, a Markdown file, a JSON file and a SVG file, all named with the hash of the commit which was [assessed by the codebase stewards](https://publiccode.net/standard-for-public-code/) at the Foundation for Public Code.
Through the website published, compliance for a specific commit can be verified, and commits not in compliance will result in a `404 Page not found` error.

## Structure

The folder structure is based on the URL to the repository of a codebase; commonly it shows the platform, organization name and repository name.
For example, the path for the Standard for Public Code assessment would be `github.com/publiccodenet/standard`.
In that directory all files that records the compliance with the Standard for Public Code would be found.

## File contents and usage

### Markdown

This file contains what version of the Standard for Public Code the codebase was assessed against.
It also contains the link to the assessment and a list of who the codebase stewards approved it were.
This file is used for building the website [standard-compliant.publiccode.net](https://standard-compliant.publiccode.net).

### JSON

The JSON file contains the same information as the Markdown file but in a structured format. The keys are as follows:

* `approved_by` - list of codebase stewards approving the assessment
* `assessment_url` - has the URL to the full assessment
* `commit_id` - the hash or other unique id of the commit
* `commit_tag` - the version name that people would use
* `repository_name` - the name of the repository
* `repository_url` - has the URL to the main repository
* `standard_version` - indicates what version of the Standard the codebase was assessed against
* `status` - always with the value `compliant`

Currently, we are not using this file for anything.

### SVG

The SVG file contains the short hash of the assessed codebase.
It is a badge that can be used by the codebase community wherever they want.
Ideally, it should link to the rendered file on the standard-compliance website with the same hash so that it can be verified by anyone.

To create a badge, run `script/make-compliance-badge.sh` and provide the repository, the hash of the assessed commit of the codebase and optionally the version of the standard as parameters. For example:

```
script/make-compliance-badge.sh https://github.com/publiccodenet/standard 3cff7d0cbff22d40c180550ff05e9d05136fb69c 0.7.1
```

## List of compliant codebases

On the site [standard-compliant.publiccode.net](https://standard-compliant.publiccode.net) we publish a list of all codebases (and the corresponding commits) that have been assessed as compliant with the Standard for Public Code by the codebases stewards.

## List of committed codebases

Additionally, on the same site, we host a list of codebases have made a public commitment to meet the Standard for Public Code.
If you use a [commitment badge](https://blog.publiccode.net/news/2023/09/12/standard-for-pubic-code-commitment-badge.html) on a codebase, and aim to meet the Standard for Public Code, you are welcome to make a pull request here to add that codebase to this list.

## Add your codebase

If you have made an assessment of your codebase and think that you are ready to be added here, please send an email to the codebase stewards so that they can verify it. Send it to [codebasestewards@publiccode.net](mailto:codebasestewards@publiccode.net).

## License

This project is licensed under the CC 0 License, see the [LICENSE](LICENSE) file for details.
