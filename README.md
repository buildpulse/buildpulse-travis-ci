# Travis CI Integration for BuildPulse [![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/Workshop64/buildpulse-travis-ci/main/LICENSE)

Connect your [Travis CI](https://travis-ci.com) workflows to [BuildPulse][buildpulse.io] to help you detect, track, and eliminate flaky tests.

## Usage

1. Locate the BuildPulse credentials for your account at [buildpulse.io][]
2. In your repository settings on [travis-ci.com](https://travis-ci.com) or [travis-ci.org](https://travis-ci.org), add two [environment variables](https://docs.travis-ci.com/user/environment-variables#defining-variables-in-repository-settings):
    - One named `BUILDPULSE_ACCESS_KEY_ID` with the value set to the `BUILDPULSE_ACCESS_KEY_ID` for your account
    - One named `BUILDPULSE_SECRET_ACCESS_KEY` with the value set to the `BUILDPULSE_SECRET_ACCESS_KEY` for your account
3. Add the following `after_script` clause to your `.travis.yml`:

    ```yaml
    after_script:
      # Upload test results to BuildPulse for flaky test detection
      - export BUILDPULSE_ACCOUNT_ID=<buildpulse-account-id>
      - export BUILDPULSE_REPOSITORY_ID=<buildpulse-repository-id>
      - export BUILDPULSE_REPORT_PATH=<path-to-directory-containing-xml-reports>
      - /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Workshop64/buildpulse-travis-ci/main/uploader-for-ubuntu.sh)"
    ```

    If you already have an `after_script` clause in your `.travis.yml` file, append the steps above to your existing `after_script` clause.

4. In your `.travis.yml` file, replace `<buildpulse-account-id>` and `<buildpulse-repository-id>` with your account ID and repository ID from [buildpulse.io][]
5. Also in your `.travis.yml` file, replace `<path-to-directory-containing-xml-reports>` with the actual path containing the XML reports for your test results

[buildpulse.io]: https://buildpulse.io
