React = require 'react'
ReactDOM = require 'react-dom'
marked = require 'marked'
$ = require 'jquery'


CommentBox = React.createClass
  loadCommentsFromServer: ->
    $.ajax(
      url: @props.url
      dataType: 'json'
      cache: false
      success: (data) => @setState {data}
      error: (xhr, status, err) =>
        console.error @props.url, status, err.toString()
    )
  handleCommentSubmit: (comment) ->
    comments = @state.data
    comment.id = Date.now()
    newComments = comments.concat [comment]
    @setState data: newComments
    $.ajax(
      url: @props.url
      dataType: 'json'
      type: 'POST'
      data: comment
      success: (data) => @setState {data}
      error: (xhr, status, err) =>
        @setState data: comments
        console.error @props.url, status, err.toString()
    )
  getInitialState: -> {data: []}
  componentDidMount: ->
    @loadCommentsFromServer()
    setInterval @loadCommentsFromServer, @props.pollInterval
  render: ->
    <div className="commentBox">
     <h1>Comments</h1>
     <CommentList data={@state.data} />
     <CommentForm onCommentSubmit={@handleCommentSubmit} />
    </div>


Comment = React.createClass
  rawMarkup: ->
    rawMarkup = marked @props.children.toString(), sanitize: true
    return {__html: rawMarkup}
  render: ->
    <div className="comment">
      <h2 className="commentAuthor">
        {@props.author}
      </h2>
      <span dangerouslySetInnerHTML={@rawMarkup()} />
    </div>


CommentList = React.createClass
  render: ->
    commentNodes = @props.data.map (comment) ->
      <Comment author={comment.author} key={comment.id}>
        {comment.text}
      </Comment>
    <div className="commentList">{commentNodes}</div>


CommentForm = React.createClass
  getInitialState: -> author: '', text: ''
  handleAuthorChange: (e) -> @setState author: e.target.value
  handleTextChange: (e) -> @setState text: e.target.value
  handleSubmit: (e) ->
    e.preventDefault()
    author = @state.author.trim()
    text = @state.text.trim()
    return if not text or not author
    @props.onCommentSubmit {author, text}
    @setState author: '', text: ''
  render: ->
    <form className="commentForm" onSubmit={@handleSubmit}>
      <input
        type="text"
        placeholder="Your name"
        value={@state.author}
        onChange={@handleAuthorChange} />
      <input
        type="text"
        placeholder="Say something..."
        value={@state.text}
        onChange={@handleTextChange} />
      <input type="submit" value="Post" />
    </form>


ReactDOM.render(
  <CommentBox url="/api/comments" pollInterval={2000} />,
  document.getElementById 'content'
)
