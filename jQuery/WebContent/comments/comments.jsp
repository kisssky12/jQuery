<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>comments.jsp</title>
<style>
.comment {
	border: 1px dotted blue;
}
</style>
<script src='../js/jquery-3.5.1.min.js'></script>
<script>
	window.onload = function() {
		loadCommentList();
	}

	//목록조회;
	function loadCommentList() {
		$.ajax({
			url : '../CommentsServ',
			data : 'cmd=selectAll',
			dataType : 'xml',
			type : 'get',
			success : loadCommentResult,
			error : function(a, b) {
				alert('댓글 로딩 실패: ' + b);
			}
		});
	}
	//콜백 함수
	function loadCommentResult(xmlResult) {
		//   console.log(xmlResult);
		let xmlDoc = xmlResult;
		let code = xmlDoc.getElementsByTagName('code').item(0).firstChild.nodeValue;
		if (code == 'success') {
			let commentList = eval('('
					+ xmlDoc.getElementsByTagName('data').item(0).firstChild.nodeValue
					+ ')');
			console.log(commentList);
			let listDiv = $('#commentList');
			for (let i = 0; i < commentList.length; i++) {
				let commentDiv = makeCommentView(commentList[i]);
				listDiv.append(commentDiv);
			}
		}
	}
	function makeCommentView(comment) {
		let div = document.createElement('div'); // $('<div />')
		div.setAttribute('id', 'c' + comment.id);
		div.className = 'comment';
		div.comment = comment; // {id:2, name:홍길동, contant:내용....}

		let str = '<strong>' + comment.name + '</strong> ' + comment.content
				+ '<input type="button" value="수정" onclick="viewUpdateForm(' + comment.id + ')">'
				+ '<input type="button" value="삭제" onclick="confirmDeletion(' + comment.id + ')">';
		div.innerHTML = str;
		return div;
	}

	// 등록 ajax 호출.
	function addComment() {
		let name = document.addForm.name.value; //name의 value값
		let content = document.addForm.content.value; //content의 value값
		if (name == null || name == "") {
			alert('name is invalid');
			return;
		} else if (content == null || content == "") {
			alert('content is invalid');
			return;
		}
		let params = 'name=' + name + '&content=' + content + '&cmd=insert'; //&cmd=insert 입력하는처리

		$.ajax({
			url : '../CommentsServ',
			dataType : 'xml',
			data : params,
			success : addResult,
			error : function(a, b) {
				alert('서버 에러: ' + b)
			}
		});
	}
	// 콜백함수
	function addResult(req) {
		let xmlDoc = req;
		let code = xmlDoc.getElementsByTagName('code').item(0).firstChild.nodeValue;
		if (code == 'success') {
			let comment = eval('(' + xmlDoc.getElementsByTagName('data').item(0).firstChild.nodeValue + ')');
			let listDiv = document.getElementById('commentList');
			makeCommentView(comment);
			let commentDiv = makeCommentView(comment);
			listDiv.append(commentDiv);

			document.addForm.name.value = '';
			document.addForm.content.value = '';

			alert('등록했습니다![' + comment.id + ']');
		}
	}
	
	// 수정버튼 이벤트핸들러 viewUpdateForm
	function viewUpdateForm(commentId) {
		let commentDiv = document.getElementById('c' + commentId);
		let updateFormDiv = document.getElementById('commentUpdate');
		commentDiv.after(updateFormDiv);
		
		let comment = commentDiv.comment; // {id:??, name:??, content:??}
		document.updateForm.id.value = comment.id;
		document.updateForm.name.value = comment.name;
		document.updateForm.content.value = comment.content;
		updateFormDiv.style.display = 'block';
	}
	
	// 변경이벤트핸들러
	function updateComment() {
		let id = document.updateForm.id.value;
		let name = document.updateForm.name.value;
		let content = document.updateForm.content.value;
		let params = 'id=' + id + '&name=' + name + '&content=' + content + '&cmd=update';
		$.ajax({
			url : '../CommentsServ',
			dataType : 'xml',
			data : params,
			success : updateResult,
			error : function(a, b) {
				console.log(a,b);
			}
		});
	}
	// 변경콜백함수
	function updateResult(req) {
		let xmlDoc = req;
		let code = xmlDoc.getElementsByTagName('code').item(0).firstChild.nodeValue;
		if (code == 'success') {
			let comment = eval('('+ xmlDoc.getElementsByTagName('data').item(0).firstChild.nodeValue + ')');
			let listDiv = document.getElementById('commentList');
			let commentDiv = makeCommentView(comment);
			let oldCommentDiv = document.getElementById('c' + comment.id);
			listDiv.replaceChild(commentDiv, oldCommentDiv);
			
			document.getElementById('commentUpdate').style.display = 'none';
			alert('수정되었습니다!');
		}
	}
	// 삭제이벤트
	function confirmDeletion(id) {
				
		$.ajax({
			url : '../CommentsServ',
			dataType : 'xml',
			data : 'id=' + id + '&cmd=delete',
			success : deleteResult,
			error : function(a, b) {
				console.log(a,b);
			}
		});
	}
	// 삭제콜백함수
	function deleteResult(req) {
		let xmlDoc = req;
		let code = xmlDoc.getElementsByTagName('code').item(0).firstChild.nodeValue;
		if (code == 'success') {
			let comment = eval('('+ xmlDoc.getElementsByTagName('data').item(0).firstChild.nodeValue + ')');
			let listDiv = document.getElementById('commentList');
			let commentDiv = document.getElementById('c' + comment.id);
			listDiv.removeChild(commentDiv);
			
			alert('삭제되었습니다!');
		}
	}
	
</script>
</head>
<body>
	<div id='commentList'></div>

	<!-- 글등록화면 -->
	<div id='commentAdd'>
		<form action="" name="addForm">
			이름: <input type="text" name="name" size="10"><br> 내용:
			<textarea name="content" cols="20" rows="2"></textarea>
			<br> <input type="button" value="등록" onclick="addComment()">
		</form>
	</div>

	<!-- 글수정화면 -->
	<div id="commentUpdate" style="display: none;">
		<form action="" name="updateForm">
			<input type="hidden" name="id" value=""> 
			이름: <input	type="text" name="name" size="10"><br> 
			내용: <textarea name="content" cols="20" rows="2"></textarea><br> 
			<input type="button" value="변경" onclick="updateComment()">
			<input type="button" value="취소" onclick="cancelUpdate()">
		</form>
	</div>
</body>
</html>