var rhit = rhit || {};

rhit.FB_COLLECTION_USERS = "Users";
rhit.FB_COLLECTION_REPLIES = "replies";

rhit.FB_KEY_NAME = "name";
rhit.FB_KEY_PHOTO_URL = "photoUrl";
rhit.FB_KEY_TITLE = "title";
rhit.FB_KEY_CONTENT = "content";
rhit.FB_KEY_LAST_TOUCHED = "lastTouched";
rhit.FB_KEY_AUTHOR = "author";
rhit.FB_KEY_TEXT = "text";
rhit.FB_KEY_PARENT_ID = "parentId";

rhit.FB_KEY_PREFERED_FONT_SIZE = "preferedFontSize";
rhit.FONT_SIZE_SMALL = "styles/fontSizes/small.css";
rhit.FONT_SIZE_MEDIUM = "styles/fontSizes/medium.css";
rhit.FONT_SIZE_LARGE = "styles/fontSizes/large.css";

rhit.FB_KEY_PREFERED_FONT_TYPE = "preferedFontType";
rhit.FONT_OPTION1 = "styles/fontTypes/option1.css";
rhit.FONT_OPTION2 = "styles/fontTypes/option2.css";
rhit.FONT_OPTION3 = "styles/fontTypes/option3.css";


rhit.fbPostManager = null;
rhit.fbSinglePostManager = null;
rhit.fbAuthManager = null;
rhit.fbUserManager = null;
rhit.fbRepliesManager = null;
rhit.focusedReply = null;
rhit.fbSingleReplyManager = null;


//From: https://stackoverflow.com/questions/494143/creating-a-new-dom-element-from-an-html-string-using-built-in-dom-methods-or-pro/35385518#35385518
function htmlToElement(html) {
	var template = document.createElement('template');
	html = html.trim();
	template.innerHTML = html;
	return template.content.firstChild;
}
//From https://gist.github.com/christoph-codes/bf7b6ce4dd5b10e3cf4ba59b571dfdc4
function convertTimestamp(timestamp) {
	let date = timestamp.toDate();
	let mm = date.getMonth();
	let dd = date.getDate();
	let yyyy = date.getFullYear();

	date = mm + '/' + dd + '/' + yyyy;
	return date;
}

// --------------------------------------------------------------------------------

// Below are the page controllers

// --------------------------------------------------------------------------------

rhit.LoginPageController = class {
	constructor() {
		document.querySelector("#roseFireButton").onclick = (event) => {
			console.log("Click sign in button");
			rhit.fbAuthManager.signIn();
		};

	}
};

rhit.SideNavController = class {
	constructor() {
		const profileItem = document.querySelector("#menuGoToProfilePage");
		if (profileItem) {
			profileItem.addEventListener("click", (event) => {
				window.location.href = "/userpage.html";
			});
		}

		const signOutItem = document.querySelector("#menuSignOut");
		if (signOutItem) {
			signOutItem.addEventListener("click", (event) => {
				rhit.fbAuthManager.signOut();
			});
		}

		const mainPageItem = document.querySelector("#menuGoToMainPage");
		if (mainPageItem) {
			mainPageItem.addEventListener("click", (event) => {
				window.location.href = "/mainpage.html";
			});
		}
	}
};

rhit.MainPageController = class {

	constructor() {
		document.querySelector("#general").addEventListener("click", (event) => {
			window.location.href = "/postList.html?topic=general";
		});

		document.querySelector("#homework").addEventListener("click", (event) => {
			window.location.href = "/postList.html?topic=homework";
		});

		document.querySelector("#clubs").addEventListener("click", (event) => {
			window.location.href = "/postList.html?topic=clubs";
		});

		document.querySelector("#res").addEventListener("click", (event) => {
			window.location.href = "/postList.html?topic=res";
		});

		// This is what allows us to change stylesheets
		rhit.fbUserManager.beginListening(rhit.fbAuthManager.uid, this.updateView.bind(this));
	}

	updateView() {
		document.getElementById("fontSizeStylesheet").setAttribute('href', rhit.fbUserManager.preferedFontSize);
		document.getElementById("fontTypeStylesheet").setAttribute('href', rhit.fbUserManager.preferedFontType);
	}
};

rhit.UserPageController = class {
	constructor() {
		this.tempFile = null;

		// Button for changing profilephoto
		document.querySelector("#browseForPhotoButton").addEventListener("click", (event) => {
			document.querySelector("#profilePhotoInput").click();
		});
		
		document.querySelector("#profilePhotoInput").addEventListener("change", (event) => {
			this.tempFile = event.target.files[0];
			document.querySelector("#fileUploadedLabel").textContent = this.tempFile.name;
		});

		document.querySelector("#submitChangeAvatarButton").addEventListener("click", (event) => {
			rhit.fbUserManager.uploadPhotoToStorage(this.tempFile);
			this.tempFile = null;
		});
		// End button for profile photo

		//Change on screen name
		document.querySelector("#submitChangeScreenNameButton").addEventListener("click", (event) => {
			const name = document.querySelector("#inputScreenName").value;
			console.log("name", name);
			rhit.fbUserManager.updateName(name);
		});


		// Below is the font type stuff
		document.querySelector("#font1Button").addEventListener("click", (event) => {
			rhit.fbUserManager.updateFontType(rhit.FONT_OPTION1);
		});

		document.querySelector("#font2Button").addEventListener("click", (event) => {
			rhit.fbUserManager.updateFontType(rhit.FONT_OPTION2);
		});

		document.querySelector("#font3Button").addEventListener("click", (event) => {
			rhit.fbUserManager.updateFontType(rhit.FONT_OPTION3);
		});

		// Below is the font size stuff
		document.querySelector("#smallFontButton").addEventListener("click", (event) => {
			rhit.fbUserManager.updateFontSize(rhit.FONT_SIZE_SMALL);
		});

		document.querySelector("#mediumFontButton").addEventListener("click", (event) => {
			rhit.fbUserManager.updateFontSize(rhit.FONT_SIZE_MEDIUM);
		});

		document.querySelector("#largeFontButton").addEventListener("click", (event) => {
			rhit.fbUserManager.updateFontSize(rhit.FONT_SIZE_LARGE);
		});
		// End font size buttons

		// This is what allows us to change stylesheets
		rhit.fbUserManager.beginListening(rhit.fbAuthManager.uid, this.updateView.bind(this));
	}

	updateView() {
		if (rhit.fbUserManager.photoUrl) {
			document.querySelector("#profilePhoto").src = rhit.fbUserManager.photoUrl;
		}

		document.getElementById("fontSizeStylesheet").setAttribute('href', rhit.fbUserManager.preferedFontSize);
		document.getElementById("fontTypeStylesheet").setAttribute('href', rhit.fbUserManager.preferedFontType);
	}
};

rhit.Post = class {
	constructor(id, title, content, author, photoUrl) {
		this.id = id;
		this.title = title;
		this.content = content;
		this.author = author;
		this.photoUrl = photoUrl;
	}
};

rhit.Reply = class {
	constructor(id, text, parentId, author, lastTouched) {
		this.id = id;
		this.text = text;
		this.parentId = parentId;
		this.author = author;
		this.lastTouched = lastTouched;
	}
};

rhit.ListPageController = class {
	constructor(topic) {
		this.topic = topic;
		document.querySelector("#submitPost").addEventListener("click", (event) => {
			const title = document.querySelector("#inputPostTitle").value;
			const content = document.querySelector("#inputPostText").value;
			const photoUrl = document.querySelector("#inputPhotoUrl").value;
			rhit.fbPostManager.add(title, content, photoUrl);
			var audio = new Audio('audio/game-start-6104.mp3');
			audio.play();
		});

		document.querySelector("#myPosts").addEventListener("click", (event) => {
			window.location.href = `/postList.html?topic=${topic}&uid=${rhit.fbAuthManager.uid}`;
		});

		document.querySelector("#allPosts").addEventListener("click", (event) => {
			window.location.href = `/postList.html?topic=${topic}`;

		});

		$('#addPostDialog').on('show.bs.modal', (event) => {
			document.querySelector("#inputPostTitle").value = "";
			document.querySelector("#inputPostText").value = "";
			console.log("dialog about to show up");
			var audio = new Audio('audio/game-start-6104.mp3');
			audio.play();

		});
		$('#addPostDialog').on('shown.bs.modal', (event) => {
			console.log("dialog is now visible");
			document.querySelector("#inputPostTitle").focus();
			var audio = new Audio('audio/game-start-6104.mp3');
			audio.play();
		});

		//Start listening
		rhit.fbPostManager.beginListening(this.updateList.bind(this));
		// This is what allows us to change stylesheets
		rhit.fbUserManager.beginListening(rhit.fbAuthManager.uid, this.updateView.bind(this));
	}

	updateList() {
		// update the page header
		if(this.topic == "general"){
			document.querySelector("#pageHeader").textContent = " General Discusion Board";
			var audio = new Audio('audio/game-start-6104.mp3');
			audio.play();
		}
		if(this.topic == "homework"){
			document.querySelector("#pageHeader").textContent =  "Homework Discusion Board";
			var audio = new Audio('audio/game-start-6104.mp3');
			audio.play();
		}
		if(this.topic == "clubs"){
			document.querySelector("#pageHeader").textContent = "Clubs/Activities Discusion Board";
			var audio = new Audio('audio/game-start-6104.mp3');
			audio.play();
		}
		if(this.topic == "res"){
			document.querySelector("#pageHeader").textContent = "Res-Life Discusion Board";
			var audio = new Audio('audio/game-start-6104.mp3');
			audio.play();
		}

		//Make a new quoteListContainer
		const newList = htmlToElement('<div id="postContainer"></div>');

		//Fill the quoteListContainer with quote cards using a loop
		for (let i = 0; i < rhit.fbPostManager.length; i++) {
			const post = rhit.fbPostManager.getPostAtIndex(i);
			const newCard = this._createPost(post);

			newCard.onclick = (event) => {
				window.location.href = `/post.html?topic=${this.topic}&id=${post.id}`;
			};
			newList.appendChild(newCard);
		}

		//Remove the old quoteListContainer
		const oldList = document.querySelector("#postContainer");
		oldList.removeAttribute("id");
		oldList.hidden = true;
		//Put in the new quoteListContainer
		oldList.parentElement.appendChild(newList);
	}

	updateView() {
		document.getElementById("fontSizeStylesheet").setAttribute('href', rhit.fbUserManager.preferedFontSize);
		document.getElementById("fontTypeStylesheet").setAttribute('href', rhit.fbUserManager.preferedFontType);
	}

	_createPost(post) {

		return htmlToElement(`<div class="card mb-3"">
		<div class="row no-gutters">
		  <div class="col-md-4">
			<img src=${post.photoUrl || "images/rose_logo.png"} class="card-img" alt="post thumbnail">
		  </div>
		  <div class="col-md-8">
			<div class="card-body">
			  <h5 class="card-title header-font">${post.title}</h5>
			  <h6 class="card-subtitle mb-2 text-muted label-font">${post.author}</h6>
			</div>
		  </div>
		</div>
	  </div>`);
	}
};

rhit.PostPageController = class {
	constructor(topic, id) {
		this.topic = topic;
		this.parentId = id;
		this.author = rhit.fbAuthManager.uid;

		document.querySelector("#submitEditPost").addEventListener("click", (event) => {
			const title = document.querySelector("#inputTitle").value;
			const content = document.querySelector("#inputContent").value;
			const photoUrl = document.querySelector("#inputPhotoUrl").value;
			rhit.fbSinglePostManager.update(title, content, photoUrl);
		});

		$("#editPostDialog").on('show.bs.modal', (event) => {
			document.querySelector("#inputTitle").value = rhit.fbSinglePostManager.title;
			document.querySelector("#inputContent").value = rhit.fbSinglePostManager.content;
			document.querySelector("#inputPhotoUrl").value = rhit.fbSinglePostManager.photoUrl;
			var audio = new Audio('audio/game-start-6104.mp3');
			audio.play();
		});

		$("#editPostDialog").on('shown.bs.modal', (event) => {
			document.querySelector("#inputTitle").focus();
			var audio = new Audio('audio/game-start-6104.mp3');
			audio.play();
		});


		document.querySelector("#submitDeletePost").addEventListener("click", (event) => {
			rhit.fbSinglePostManager.delete().then(() => {
				window.location.href = `postList.html?topic=${this.topic}`;
			}).catch((error) => {
				console.error("Error removing document: ", error);
			});
		});

		document.querySelector("#submitReply").addEventListener("click", (event) => {
			const text = document.querySelector("#inputText").value;

			rhit.fbRepliesManager.add(text);
		});

		//Start listening
		// This is what allows us to change stylesheets
		rhit.fbUserManager.beginListening(rhit.fbAuthManager.uid, this.updateView.bind(this));
		rhit.fbSinglePostManager.beginListening(this.updateView.bind(this));

		// Do this after
		rhit.fbRepliesManager.beginListening(this.updateList.bind(this));

		

		// These are the controls for the edit and delete replies modal
		document.querySelector("#submitEditReply").addEventListener("click", (event) => {
			const text = document.querySelector("#inputNewText").value;

			console.log("Update request for " + rhit.focusedReply.id);
			rhit.fbSingleReplyManager.update(text);
		});

		$("#editReplyDialog").on('show.bs.modal', (event) => {
			document.querySelector("#inputNewText").value = rhit.focusedReply.text;
			var audio = new Audio('audio/game-start-6104.mp3');
			audio.play();
		});

		$("#editReplyDialog").on('shown.bs.modal', (event) => {
			document.querySelector("#inputNewText").focus();
		});

		document.querySelector("#submitDeleteReply").addEventListener("click", (event) => {

			console.log("Delete request for " + rhit.focusedReply.id);
			rhit.fbSingleReplyManager.delete();
		});
	}

	updateView() {
		document.getElementById("fontSizeStylesheet").setAttribute('href', rhit.fbUserManager.preferedFontSize);
		document.getElementById("fontTypeStylesheet").setAttribute('href', rhit.fbUserManager.preferedFontType);

		document.querySelector("#postTitle").textContent = rhit.fbSinglePostManager.title;
		document.querySelector("#postContent").textContent = rhit.fbSinglePostManager.content;
		document.querySelector("#postPhoto").src = rhit.fbSinglePostManager.photoUrl;

		if (rhit.fbSinglePostManager.author == rhit.fbAuthManager.uid) {
			document.querySelector("#authorActionsMenu").style.display = "flex";
		}
	}

	updateList() {
		//Make a new quoteListContainer
		const newList = htmlToElement('<div id="replyContainer"></div>');

		//Fill the quoteListContainer with quote cards using a loop
		for (let i = 0; i < rhit.fbRepliesManager.length; i++) {
			const reply = rhit.fbRepliesManager.getReplyAtIndex(i);
			let displayType = "none";
			if (reply.author == this.author) {
				displayType = "flex";
			}
			const newCard = this._createReply(reply, displayType);

			new rhit.FbSingleReplyManager(reply, newCard);
			newList.appendChild(newCard);
		}

		//Remove the old quoteListContainer
		const oldList = document.querySelector("#replyContainer");
		oldList.removeAttribute("id");
		oldList.hidden = true;
		//Put in the new quoteListContainer
		oldList.parentElement.appendChild(newList);
	}

	_createReply(reply, diplayType) {

		return htmlToElement(`
		<div class="reply">
			<hr>
			<div class="reply-content">
			
				<div class="reply-header list-group-item label-font">
					<div class="reply-author label-font">${reply.author}:</div>
					<div class="reply-timestamp label-font">${convertTimestamp(reply.lastTouched)}</div>
					<div class="dropdown pull-xs-right">
					<button style="display:${diplayType};" class="btn bmd-btn-icon dropdown-toggle" type="button" id="replyActionsMenu" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
						<i class="material-icons">more_vert</i>
					</button>
					
					<div class="dropdown-menu dropdown-menu-right" aria-labelledby="replyActionsMenu">
						<button id="menuEdit" class="dropdown-item" type="button" data-toggle="modal" data-target="#editReplyDialog">
						<i class="material-icons">edit</i>&nbsp;&nbsp;&nbsp;Edit
						</button>
					
						<button id="menuDelete" class="dropdown-item" type="button" data-toggle="modal" data-target="#deleteReplyDialog">
						<i class="material-icons">delete</i>&nbsp;&nbsp;&nbsp;Delete
						</button>
					</div>
					</div>
				</div>

				<div class="reply-text label-font">${reply.text}</div>
			</div>
	  	</div>
		`);
	}
};

// --------------------------------------------------------------------------------

// Below are the managers

// --------------------------------------------------------------------------------


rhit.fbPostManager = class {
	constructor(uid, topic) {
		this.uid = uid;
		this.topic = topic;
		this._documentSnapshots = [];
		this._ref = firebase.firestore().collection(this.topic);
		this._unsubscribe = null;
	}

	add(title, content, photoUrl) {
		// Add a new document with a generated id.
		
		this._ref.add({
			[rhit.FB_KEY_PHOTO_URL]: photoUrl,
			[rhit.FB_KEY_TITLE]: title,
			[rhit.FB_KEY_CONTENT]: content,
			[rhit.FB_KEY_AUTHOR]: rhit.fbAuthManager.uid,
			[rhit.FB_KEY_LAST_TOUCHED]: firebase.firestore.Timestamp.now(),
		})
			.then(function (docRef) {
				console.log("Document written with ID: ", docRef.id);
			})
			.catch(function (error) {
				console.error("Error adding document: ", error);
			});
	}

	beginListening(changeListener) {

		let query = this._ref.orderBy(rhit.FB_KEY_LAST_TOUCHED, "desc").limit(50);
		if (this.uid) {
			query = query.where(rhit.FB_KEY_AUTHOR, "==", this.uid);
			// This block is what allows us to only see the posts we made
		}
		this._unsubscribe = query.onSnapshot((querySnapshot) => {
			console.log("GeneralPost update!");
			this._documentSnapshots = querySnapshot.docs;
			changeListener();
		});
	}

	stopListening() {
		this._unsubscribe();
	}

	get length() {
		return this._documentSnapshots.length;
	}

	getPostAtIndex(index) {
		const docSnapshot = this._documentSnapshots[index];
		const post = new rhit.Post(docSnapshot.id,
			docSnapshot.get(rhit.FB_KEY_TITLE),
			docSnapshot.get(rhit.FB_KEY_CONTENT),
			docSnapshot.get(rhit.FB_KEY_AUTHOR),
			docSnapshot.get(rhit.FB_KEY_PHOTO_URL));
		return post;
	}
};

rhit.FbAuthManager = class {
	constructor() {
		this._user = null;
		this.name = "";
		this.photoUrl ="";
		console.log("You have made the Auth Manager");
	}

	beginListening(changeListener) {
		firebase.auth().onAuthStateChanged((user) => {
			this._user = user;
			changeListener();
		});
	}

	signIn() {
		console.log("TODO: Sign in using Rosefire");

		Rosefire.signIn("995ca471-b048-4886-91a1-da1c3d75fa4b", (err, rfUser) => {
			if (err) {
				console.log("Rosefire error!", err);
				return;
			}
			console.log("Rosefire success!", rfUser);
			var audio = new Audio('audio/game-start-6104.mp3');
			audio.play();


			firebase.auth().signInWithCustomToken(rfUser.token).catch((error) => {
				const errorCode = error.code;
				const errorMessage = error.message;

				if (errorCode === 'auth/invalid-custom-token') {
					alert('The token you provided is not valid.');
				} else {
					console.error("Cusotm auth error", errorCode, errorMessage);
				}
			});
		});
	}

	signOut() {
		firebase.auth().signOut().catch((error) => {
			console.log("Sign Out Error");
		});
		var audio = new Audio('audio/game-start-6104.mp3');
		audio.play();
	}

	get isSignedIn() {
		return !!this._user;
	}

	get uid() {
		return this._user.uid;
	}
};

rhit.fbUserManager = class {
	constructor() {
		this._collectoinRef = firebase.firestore().collection(rhit.FB_COLLECTION_USERS);
		this._document = null;
	}

	beginListening(uid, changeListener) {
		console.log("Listening for uid", uid);
		const userRef = this._collectoinRef.doc(uid);
		this._unsubscribe = userRef.onSnapshot((doc) => {
			if (doc.exists) {
				this._document = doc;
				console.log('doc.data() :', doc.data());
				if (changeListener) {
					changeListener();
				}
			} else {
				console.log("This User object does not exist! (that's bad)");
			}
		});
	}

	get isListening() {
		return !!this._unsubscribe;
	}

	stopListening() {
		this._unsubscribe();
	}

	addNewUserMaybe(uid, name, photoUrl) {
		// First check if the user already exists.
		console.log("Checking User for uid = ", uid);
		const userRef = this._collectoinRef.doc(uid);
		return userRef.get().then((document) => {
			if (document.exists) {
				console.log("User already exists.  Do nothing");
				return false; // This will be the parameter to the next .then callback function.
			} else {
				// We need to create this user.
				console.log("Creating the user!");
				return userRef.set({
					[rhit.FB_KEY_NAME]: name,
					[rhit.FB_KEY_PHOTO_URL]: photoUrl,
				}).then(() => {
					return true;
				});
			}
		});
	}

	uploadPhotoToStorage(file) {
		const metadata = {
			"content-type": file.type
		};
		const storageRef = firebase.storage().ref().child(rhit.FB_COLLECTION_USERS).child(rhit.fbAuthManager.uid);

		storageRef.put(file, metadata).then((uploadSnapshot) => {
			console.log("Upload is complete!", uploadSnapshot);

			storageRef.getDownloadURL().then((downloadURL) => {
				console.log("File available at", downloadURL);
				rhit.fbUserManager.updatePhotoUrl(downloadURL);
			});
		});
		console.log("Uploading", file.name);
	}

	updatePhotoUrl(photoUrl) {
		const userRef = this._collectoinRef.doc(rhit.fbAuthManager.uid);
		userRef.update({
			[rhit.FB_KEY_PHOTO_URL]: photoUrl
		})
			.then(() => {
				console.log("Document successfully updated with photoUrl!");
			})
			.catch(function (error) {
				console.error("Error updating document: ", error);
			});
	}

	updateName(name) {
		const userRef = this._collectoinRef.doc(rhit.fbAuthManager.uid);
		return userRef.update({
			[rhit.FB_KEY_NAME]: name
		})
			.then(() => {
				console.log("Document successfully updated with name!");
			})
			.catch(function (error) {
				console.error("Error updating document: ", error);
			});
	}

	updateFontSize(size) {
		const userRef = this._collectoinRef.doc(rhit.fbAuthManager.uid);
		return userRef.update({
			[rhit.FB_KEY_PREFERED_FONT_SIZE]: size
		})
			.then(() => {
				console.log("Document successfully updated with prefered font size");
			})
			.catch(function (error) {
				console.error("Error updating document: ", error);
			});
	}

	updateFontType(type) {
		const userRef = this._collectoinRef.doc(rhit.fbAuthManager.uid);
		return userRef.update({
			[rhit.FB_KEY_PREFERED_FONT_TYPE]: type
		})
			.then(() => {
				console.log("Document successfully updated with prefered font type");
			})
			.catch(function (error) {
				console.error("Error updating document: ", error);
			});
	}

	get name() {
		return this._document.get(rhit.FB_KEY_NAME);
	}

	get preferedFontSize() {
		return this._document.get(rhit.FB_KEY_PREFERED_FONT_SIZE);
	}

	get preferedFontType() {
		return this._document.get(rhit.FB_KEY_PREFERED_FONT_TYPE);
	}

	get photoUrl() {
		return this._document.get(rhit.FB_KEY_PHOTO_URL);
	}
};

rhit.FbSingleReplyManager = class {
	constructor(reply, card) {
		this.card = card;
		this.reply =  reply;
		this._ref = firebase.firestore().collection(rhit.FB_COLLECTION_REPLIES).doc(this.reply.id);

		// This focuses the document to the correct reply
		this.card.querySelector("#replyActionsMenu").addEventListener("click", (event) => {
			console.log(`Clicked menu for ${reply.id}`);
			rhit.focusedReply = this.reply;
			rhit.fbSingleReplyManager = this;
		});
	}

	update(text) {
		this._ref.update({
			[rhit.FB_KEY_TEXT]: text,
			[rhit.FB_KEY_LAST_TOUCHED]: firebase.firestore.Timestamp.now(),
		})
		.then(() => {
			console.log("Document successfully updated");
		})
		.catch(function(error) {
			console.error("Error updating document: ", error);
		});
	}

	delete() {
		return this._ref.delete();
	}
};

rhit.FbSinglePostManager = class {
	constructor(postId, topic) {
		this.postId = postId;
		this.topic = topic;
		this._documentSnapshot = {};
	  	this._unsubscribe = null;
	  	this._ref = firebase.firestore().collection(this.topic).doc(postId);
	}

	beginListening(changeListener) {
		this._unsubscribe = this._ref.onSnapshot((doc) => {
			if (doc.exists) {
				console.log("Document data:", doc.data());
				this._documentSnapshot = doc;
				changeListener();
			} else { 
				console.log("No such document");
			}
		});
	}

	stopListening() {
	  	this._unsubscribe();
	}

	update(title, content, photoUrl) {
		this._ref.update({
			[rhit.FB_KEY_PHOTO_URL]: photoUrl,
			[rhit.FB_KEY_TITLE]: title,
			[rhit.FB_KEY_CONTENT]: content,
			[rhit.FB_KEY_LAST_TOUCHED]: firebase.firestore.Timestamp.now(),
		})
		.then(() => {
			console.log("Document successfully updated");
		})
		.catch(function(error) {
			console.error("Error updating document: ", error);
		});
	}

	delete() {
		return this._ref.delete();
	}

	get title() {
		return this._documentSnapshot.get(rhit.FB_KEY_TITLE);
	}

	get content() {
		return this._documentSnapshot.get(rhit.FB_KEY_CONTENT);
	}

	get photoUrl() {
		return this._documentSnapshot.get(rhit.FB_KEY_PHOTO_URL);
	}

	get author() {
		return this._documentSnapshot.get(rhit.FB_KEY_AUTHOR);
	}
};

rhit.fbRepliesManager = class {
	constructor(parentPostId) {
		this.parentPostId = parentPostId;
		this._documentSnapshots = [];
		this._ref = firebase.firestore().collection(rhit.FB_COLLECTION_REPLIES);
		this._unsubscribe = null;
	}

	add(text) {
		this._ref.add({
			[rhit.FB_KEY_TEXT]: text,
			[rhit.FB_KEY_PARENT_ID]: this.parentPostId,
			[rhit.FB_KEY_AUTHOR]: rhit.fbAuthManager.uid,
			[rhit.FB_KEY_LAST_TOUCHED]: firebase.firestore.Timestamp.now(),
		})
			.then(function (docRef) {
				console.log("Document written with ID: ", docRef.id);
			})
			.catch(function (error) {
				console.error("Error adding document: ", error);
			});
	}

	beginListening(changeListener) {

		let query = this._ref.orderBy(rhit.FB_KEY_LAST_TOUCHED, "desc").limit(50);
		query = query.where(rhit.FB_KEY_PARENT_ID, "==", rhit.fbSinglePostManager.postId);
		// This is what makes it so we only load replies to this post
		this._unsubscribe = query.onSnapshot((querySnapshot) => {
			console.log("GeneralPost update!");
			this._documentSnapshots = querySnapshot.docs;
			changeListener();
		});
	}

	stopListening() {
		this._unsubscribe();
	}

	get length() {
		return this._documentSnapshots.length;
	}

	getReplyAtIndex(index) {
		const docSnapshot = this._documentSnapshots[index];
		const reply = new rhit.Reply(
			docSnapshot.id,
			docSnapshot.get(rhit.FB_KEY_TEXT),
			docSnapshot.get(rhit.FB_KEY_PARENT_ID),
			docSnapshot.get(rhit.FB_KEY_AUTHOR),
			docSnapshot.get(rhit.FB_KEY_LAST_TOUCHED));
		return reply;
	}
};

// --------------------------------------------------------------------------------

// Below is the main stuff

// --------------------------------------------------------------------------------


rhit.checkForRedirects = function () {
	if (document.querySelector("#loginPage") && rhit.fbAuthManager.isSignedIn) {
		window.location.href = "/mainpage.html";
	}
	if (!document.querySelector("#loginPage") && !rhit.fbAuthManager.isSignedIn) {
		window.location.href = "/";
	}
};

rhit.initializePage = function () {
	const urlParams = new URLSearchParams(window.location.search);
	new rhit.SideNavController();

	let fontSizeStyleSheet = document.getElementById("fontSizeStylesheet");

	if (document.querySelector("#loginPage")) {
		console.log("You are on the login page");
		new rhit.LoginPageController();
	}

	if (document.querySelector("#mainPage")) {
		console.log("You are on the main page");
		new rhit.MainPageController();
	}

	if (document.querySelector("#userPage")) {
		console.log("You are on the user page");
		new rhit.UserPageController();
	}

	if (document.querySelector("#listPage")) {
		
		const uid = urlParams.get("uid");
		const topic = urlParams.get("topic");
		console.log("You are on the list page for: " + topic);

		rhit.fbPostManager = new rhit.fbPostManager(uid, topic);
		new rhit.ListPageController(topic);
	}

	if(document.querySelector("#postPage")) {
		console.log("You are on the post page");

		const postId = urlParams.get("id");
		const topic = urlParams.get("topic");

		if(!postId) {
			console.log("Error!  Missing post id!");
			window.location.href = "/";
		}

		rhit.fbSinglePostManager = new rhit.FbSinglePostManager(postId, topic);
		rhit.fbRepliesManager = new rhit.fbRepliesManager(postId);
		new rhit.PostPageController(topic, postId);
	}
};

rhit.createUserObjectIfNeeded = function () {
	return new Promise((resolve, reject) => {
		if (!rhit.fbAuthManager.isSignedIn) {
			console.log("Nobody is signed in.  No need to check if this is a new User");
			resolve(false);
			return;
		}
		if (!document.querySelector("#loginPage")) {
			console.log("We're not on the login page.  Nobody is signing in for the first time.");
			resolve(false);
			return;
		}
		rhit.fbUserManager.addNewUserMaybe(
			rhit.fbAuthManager.uid,
			rhit.fbAuthManager.name,
			rhit.fbAuthManager.photoUrl).then((wasUserAdded) => {
				resolve(wasUserAdded);
			});
	});
};


rhit.main = function () {
	console.log("Ready");
	rhit.fbUserManager = new rhit.fbUserManager();
	rhit.fbAuthManager = new rhit.FbAuthManager();


	rhit.fbAuthManager.beginListening(() => {
		console.log("isSignedIn = ", rhit.fbAuthManager.isSignedIn);

		rhit.createUserObjectIfNeeded().then((isUserNew) => {
			console.log('isUserNew :>> ', isUserNew);
			if (isUserNew) {
				window.location.href = "/userpage.html";
				return;
			}
			rhit.checkForRedirects();
			rhit.initializePage();
		});

		console.log("This code runs before any async code returns.");
	});
};


rhit.main();
