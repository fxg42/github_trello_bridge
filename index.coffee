# Copyright (C) 2014  CODE3 Coopérative de solidarité
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

_ = require 'underscore'
async  = require 'async'
program = require 'commander'
Trello = require 'node-trello'
GitHub = require 'github'

GITHUB_USERNAME = process.env.GITHUB_USERNAME
GITHUB_PASSWORD = process.env.GITHUB_PASSWORD
TRELLO_API_KEY = process.env.TRELLO_API_KEY
TRELLO_WRITE_ACCESS_TOKEN = process.env.TRELLO_WRITE_ACCESS_TOKEN

program
  .version '0.0.1'
  .option '-b, --trello_board <value>', 'Trello board id or short id'
  .option '-l, --trello_issue_list <value>', 'Trello list id to create new cards in'
  .option '-o, --github_repo_owner <value>', 'GitHub repo owner\'s username'
  .option '-r, --github_repo <value>', 'GitHub repo name'
  .parse process.argv

TRELLO_BOARD_ID = program.trello_board
TRELLO_NEW_ISSUES_LIST_ID = program.trello_issue_list
GITHUB_REPO_OWNER = program.github_repo_owner
GITHUB_REPO = program.github_repo

trello = new Trello(TRELLO_API_KEY, TRELLO_WRITE_ACCESS_TOKEN)

findAllIssues = (callback) ->
  github = new GitHub({version:'3.0.0'})
  github.authenticate({type:'basic', username:GITHUB_USERNAME, password:GITHUB_PASSWORD})
  github.issues.repoIssues {user:GITHUB_REPO_OWNER, repo:GITHUB_REPO}, callback

findAllCards = (callback) ->
  trello.get "/1/boards/#{TRELLO_BOARD_ID}/cards/all", callback

cardName = (issue) ->
  "[Issue \##{issue.number}] (#{issue.state}) #{issue.title}"

cardDesc = (issue) ->
  "#{issue.body} https://github.com/#{GITHUB_REPO_OWNER}/#{GITHUB_REPO}/issues/#{issue.number}"

updateCard = (card, issue, callback) ->
  payload =
    name: cardName(issue)
    desc: cardDesc(issue)
  trello.put "/1/cards/#{card.id}", payload, callback

createCard = (issue, callback) ->
  payload =
    name: cardName(issue)
    desc: cardDesc(issue)
    labels: 'yellow'
    idList: TRELLO_NEW_ISSUES_LIST_ID
    due: null
    urlSource: null
  trello.post '/1/cards', payload, callback

createOrUpdateCard = (allCards, issue, callback) ->
  re = new RegExp("^\\[Issue \##{issue.number}\\]")
  card = _.find allCards, (it) -> re.test(it.name)
  if card
    updateCard(card, issue, callback)
  else
    createCard(issue, callback)

async.parallel {issues:findAllIssues, cards:findAllCards}, (err, {issues, cards}) ->
  throw err if err
  async.each issues, async.apply(createOrUpdateCard, cards), (err) ->
    throw err if err
