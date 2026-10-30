<p align="center">
  <a href="https://nimblehq.co/">
    <picture>
      <source media="(prefers-color-scheme: dark)" srcset="https://assets.nimblehq.co/logo/dark/logo-dark-text-320.png">
      <img alt="Nimble logo" src="https://assets.nimblehq.co/logo/light/logo-light-text-320.png">
    </picture>
  </a>
</p>

<h3 align="center">Publish Github Wiki Action</h3>
<p align="center">This action helps syncs your project's documentation with your project's Github Wiki.</p>

-------

## Usage

Add the following job to an existing workflow or a new one. The job needs the `contents: write` permission, so the workflow's `GITHUB_TOKEN` can push to the Wiki.

```yml
jobs:
  publish_wiki:
    runs-on: ubuntu-latest
    permissions:
      contents: write
    steps:
      - uses: actions/checkout@v4

      - name: Publish Github Wiki
        uses: nimblehq/publish-github-wiki-action@v1.1
```

All inputs are optional:

| Input | Default | Purpose |
|---|---|---|
| `user_access_token` | The workflow `GITHUB_TOKEN` | The token that pushes to the Wiki |
| `user_name` | `github-actions[bot]` | The name on the Wiki commits |
| `user_email` | `41898282+github-actions[bot]@users.noreply.github.com` | The email on the Wiki commits |

To publish as your own user or bot, pass a Personal Access Token and its account details:

```yml
- name: Publish Github Wiki
  uses: nimblehq/publish-github-wiki-action@v1.1
  with:
    user_name: John Smith
    user_email: john_smith@email.com
    user_access_token: ${{ secrets.USER_ACCESS_TOKEN }}
```

The action fails when it cannot clone or push to the Wiki. When `.github/wiki` matches the Wiki already, it makes no commit.

<!-- TODO: Allow users to customize the wiki directory folder -->
This workflow will synchronize the `.github/wiki` folder with your project's Github Wiki.

## Setup

To use this workflow, your project must have the following:

- The Github Wiki must be enabled and initialized.
- The job must have the `contents: write` permission, or a classic Personal Access Token with the `repo` scope must be provided to the workflow.

Below are steps to ensure proper setup:

1. **Enable the Wiki feature**

   You can enable the Wiki through your project's "Settings" tab.

   ![Wiki Feature in Settings](https://user-images.githubusercontent.com/34730459/162665798-a6464c67-c74a-427e-9221-4df8310fe9cb.png)

2. **Create at least one Wiki Page in the "Wiki" tab**

   This is required to initialize the project's Wiki repository.

   ![Create Wiki Page](https://user-images.githubusercontent.com/34730459/162666191-5f8cf77b-925f-4bec-b3b9-4ae4996444a9.png)

3. **Optional: create a classic Personal Access Token with the `repo` scope enabled**

   Skip this step and the next one when the job uses the default `GITHUB_TOKEN`. Use the default token or a classic token. Do not use a fine-grained token. Issue [#16](https://github.com/nimblehq/publish-github-wiki-action/issues/16) reports that one with write access cannot push to a Wiki.

   Navigate to the [Personal Access Token](https://github.com/settings/tokens) page under the "Developer Settings" in your **user/bot account** "Settings" and generate the token.

   ![Generate Token](https://user-images.githubusercontent.com/34730459/162668740-b0ef45da-0985-4953-80c7-c60c35f5aefa.png)

   Ensure your token is copied/saved for the next step.

4. **Add the created Personal Access Token as a secret**

   Navigate to "Secrets > Actions" under the projects "Settings" tab to add a secret.

   ![Add new secret](https://user-images.githubusercontent.com/34730459/162669143-6fe258ad-b058-48a1-9c7b-dcbb1ecd0452.png)

## License

This project is Copyright (c) 2014 and onwards Nimble. It is free software
and may be redistributed under the terms specified in the [LICENSE] file.

[LICENSE]: /LICENSE

## About

<a href="https://nimblehq.co/">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://assets.nimblehq.co/logo/dark/logo-dark-text-160.png">
    <img alt="Nimble logo" src="https://assets.nimblehq.co/logo/light/logo-light-text-160.png">
  </picture>
</a>

This project is maintained and funded by Nimble.

We love open source and do our part in sharing our work with the community!
See [our other projects][community] or [hire our team][hire] to help build your product.

[community]: https://github.com/nimblehq
[hire]: https://nimblehq.co/
