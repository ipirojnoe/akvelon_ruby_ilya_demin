function docReady(fn) {
  // see if DOM is already available
  if (document.readyState === "complete" || document.readyState === "interactive") {
      // call on next available tick
      setTimeout(fn, 1);
  } else {
      document.addEventListener("DOMContentLoaded", fn);
  }
}

docReady(function(){
  async function getDirectoryObjects(api_url) {
    fetch(api_url)
    .then(response => response.json())
    .then(data => setTable(data));
  }

  function setTable(data){ 
    let _html = `<tr>
                  <td></td>
                  <td><a href="#" class="icon back-icon fas fa-arrow-left" data-href="${data.last_directory}"></a></td>
                  <td></td>
                  <td></td>
                </tr>`;
  
    let directories = data.directories
    let files = data.files
    let myTable = document.getElementsByTagName('tbody')[0];              
    for(let i = 0; i < directories.length; i++){
      _html += `<tr>
                 <td class="td-icon"><i class="icon fas fa-folder"></i></td>
                 <td><a href="#" data-href="${data.current_directory}${directories[i].name}">${directories[i].name}</a></td>
                 <td>${directories[i].updated_at}</td>
                 <td>${directories[i].size}</td>
             </tr>`;
     }
  
     for(let i = 0; i < files.length; i++){
      _html += `<tr>
                 <td class="td-icon"><i class="icon fas fa-file"></i></td>
                 <td>${files[i].name}</td>
                 <td>${files[i].updated_at}</td>
                 <td>${files[i].size}</td>
             </tr>`;
     }
     
    myTable.innerHTML = _html;

    let newHandle = function(e) { 
      if (e.target.tagName === "A") {
        e.preventDefault();
        getDirectoryObjects(window.location.origin + "/api/files?dir=" + e.target.getAttribute("data-href"));
     }};

     if(!window.isListenerSet){
      window.addEventListener("click", newHandle, false);
      window.isListenerSet = true;
     }
    
  };
  
  getDirectoryObjects(window.location.origin + "/api/files");
});
