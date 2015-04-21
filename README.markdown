## What is Showcase?
Showcase is an open-source framework for quickly generating a portfolio web site to showcase your projects with image slideshow galleries, link to GitHub repository, and integrated blog that supports embedded code. It's easy to use, with a collection of rake tasks to simplify development.

It's written in semantic HTML5, pre-styled with a clean, mobile-friendly theme that's also highly customizable. Best of all, it's built on top of Jekyll -- since GitHub Pages are powered by Jekyll, your site is ready to deploy in minutes, for free.


### Portfolio Features
Want to showcase your design skills in a separate portfolio from your site builds and web apps? This framework supports multiple portfolios.

1. **Multiple portfolio support** and as many projects per portfolio as you want
2. **Project page layouts with slideshow gallery** using the SlickJS image carousel library
3. **Projects have dedicated image gallery folders** to easily manage project-specific images like app demo screenshots, mock-ups, etc.
4. **Third-party integration is simple** with built-in support for GitHub Repositories and Google Analytics
5. **Compatible with Octopress themes** that use the classic directory structure

### Blog Features
1. **Posts and Drafts** plus site preview with and without drafts
2. **Publish or Unpublish multiple posts at once** with a single rake task
3. **Third-party integration** with built-in support for Disqus Comments and social media sharing (Twitter, Facebook, Delicious, Pinboard)

## Quickstart

**Requires:**
1. Ruby > 1.9.3
2. [Git](http://git-scm.com/)
3. An ExecJS supported JavaScript runtime ([see list](https://github.com/sstephenson/execjs))

The Quickstart assumes you have a basic understanding of command line, git, and ruby/bundler. If that sounds daunting, Showcase probably isn't for you.

**Set up Showcase**  
```
$ git clone git://github.com/femmestem/showcase.git Showcase
$ cd Showcase
```

**Install dependencies**  
```
$ gem install bundler
$ rbenv rehash # If you use rbenv, you must rehash to run the bundle command
$ bundle install
```

**Install the default Showcase theme**  
`$ rake install`

## Documentation
Documentation coming soon!

Much of the site, blog, and deployment configurations are covered in the guides and documentation at [Octopress.org](http://octopress.org/docs), as this site is a portfolio-centric expansion of the Octopress 2.0 framework. Additional features are listed below.

Portfolio support is based on Jekyll Collections, an experimental feature introduced in Jekyll 2.0. The `new_portfolio` and `new_project` rake tasks set up collections for you, but if you want to peek under the hood, check out [Jekyll Collections](http://jekyllrb.com/docs/collections/).

### Some of the Rake tasks available to you:

**rake -T**  
List tasks with params and truncated descriptions

**rake -D**  
List tasks with params and full descriptions

**rake new_page[filename]**  
Creates a new page at `source/filename/index.markdown` or `source/filename.ext`

- No filename given: defaults to `new-page/index.markdown`
- Given a filename without extension: creates a new page as `filename/index.markdown`
- Given filename with extension: creates a new page as `filename.ext`

**rake new_portfolio[title]**  
Creates a new portfolio folder `source/_portfolio-title/` and a projects archive page at `source/_portfolio-title/index.html`. Also updates Jekyll::Site::Collections* list in `_config.yml` and `source/_data/collections.yml`.

- No title given: prompts for a title (otherwise defaults to `_new-portfolio/`)
- Given title: creates `_portfolio-title/`

*By registering the portfolio to Jekyll::Site::Collections, the folder becomes Liquid-accessible, e.g. `{% site.portfolio-title %}` returns an array of Document objects in `_portfolio-title/`, much like `site.pages` and `site.posts`

**rake new_project[filename]**  
Creates a new project page at `source/_portfolio-title/filename.markdown`

- No filename given: prompts for a title (otherwise defaults to "new project") and presents a selection menu to choose portfolio
- Given filename: uses filename for project title, presents a selection menu to choose portfolio
- Given _portfolio-title/filename: creates project page at `_portfolio-title/filename.markdown` (if portfolio exists)

**rake new_draft[title]**  
Creates a new post in `source/_drafts/`

Draft posts are ignored when Jekyll builds the site for preview, generate, and deploy tasks. To preview your site with draft posts included, use `rake preview[drafts]`. (Note: posts with `published: false` in the front matter will be ignored by `preview` and `preview[drafts]`)

**rake new_post[title]**  
Creates a new post in `source/_posts/`

Posts are considered published posts, included in Jekyll's site build for preview, generate, and deploy tasks. To omit a post, put `published: false` in the front matter (safest method) or use the `rake unpublish` command to revert the post to draft status in the `source/_drafts/` folder. (Note: posts will be given a _new_ datestamp when published again.)

**rake publish[title]**  
Moves draft post from `source/_drafts/title.markdown` to `source/_posts/yyyy-mm-dd-title.markdown`, updates datestamp in front matter `date:` variable, and removes `published: false` variable from front matter (if present).

- No title given: presents a selection menu of draft titles to choose from (allows multiple selections)
- Given title: publishes post if exact match is found, otherwise presents a selection menu of similar draft titles to choose from (allows multiple selections)

**rake unpublish[title]**  
Moves post from `source/_posts/yyyy-mm-dd-title.markdown` to `source/_drafts/title.markdown` and removes the front matter `date:` variable. 

- No title given: presents a menu of post titles to choose from (allows multiple selections)
- Given title: reverts post to draft if exact match is found, otherwise presents a selection menu of similar draft titles to choose from (allows multiple selections)


## License
The MIT License (MIT)

**Showcase** the portfolio and blog site generator for hackers 
Copyright © 2014-2015 Christine Feaster

**Octopress** the obsessively designed framework built for Jekyll blogging  
Copyright © 2009-2015 Brandon Mathis

**Jekyll** the blog-aware static site generator in Ruby  
Copyright © 2008-2015 Tom Preston-Werner


Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the ‘Software’), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED ‘AS IS’, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

### Be Cool
Proudly display the 'Powered by Showcase / Octopress' credit in the footer
