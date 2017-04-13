document.querySelectorAll("div[data-remote-url]").forEach(function(o){
	var url = o.getAttribute("data-remote-url");
	$.ajax({
		url: "/works/getUrl",
		method: 'post',
		data: {attach_url: url},
		dataType: 'json'
	}).done(function(json) {
		var html = "",
			message = json.message;
		if (message == 'ok') {
			var obj = json.object,
				destUrl = obj.url,
				text = obj.description || obj.title,
				image = (obj.images && obj.images.length)? obj.images[0] : null;

			if(image){
				// image.src
				html += '<div class="preview-image" style="background-image:url(' + image.src + ');"></div>';
			}
			if(text){
				var textClass = (text == obj.description)? "description" : "title";
				html += '<p class="preview-' + textClass + '">' + text + '</p>';
			}
		}
		o.innerHTML = html || message;
	});
});