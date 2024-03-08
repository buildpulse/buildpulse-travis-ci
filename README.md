# Travis CI Integration for BuildPulse [![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/buildpulse/buildpulse-travis-ci/main/LICENSE)

Connect your [Travis CI](https://travis-ci.com) workflows to [BuildPulse][buildpulse.io] to help you find and [fix flaky tests](https://buildpulse.io/products/flaky-tests).

## Usage

1. Locate the BuildPulse credentials for your account at [buildpulse.io][]
2. In your repository settings on [travis-ci.com](https://travis-ci.com) or [travis-ci.org](https://travis-ci.org), add two [environment variables](https://docs.travis-ci.com/user/environment-variables#defining-variables-in-repository-settings):
    - One named `BUILDPULSE_ACCESS_KEY_ID` with the value set to the `BUILDPULSE_ACCESS_KEY_ID` for your account
    - One named `BUILDPULSE_SECRET_ACCESS_KEY` with the value set to the `BUILDPULSE_SECRET_ACCESS_KEY` for your account
3. Add the following `after_script` clause to your `.travis.yml`:

    ```yaml
    after_script:
      # Upload test results to BuildPulse for flaky test detection
      - curl -fsSL --retry 3 https://get.buildpulse.io/test-reporter-linux-amd64 > ./buildpulse-test-reporter
      - chmod +x ./buildpulse-test-reporter
      - ./buildpulse-test-reporter submit <path> --account-id <buildpulse-account-id> --repository-id <buildpulse-repository-id>
    ```

    If you already have an `after_script` clause in your `.travis.yml` file, append the steps above to your existing `after_script` clause.

4. On the last line, replace `<path>` with the actual path containing the XML reports for your test results
5. Also on the last line, replace `<buildpulse-account-id>` and `<buildpulse-repository-id>` with your account ID and repository ID from [buildpulse.io][]

[buildpulse.io]: https://buildpulse.io
