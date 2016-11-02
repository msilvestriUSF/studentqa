$(function () {

  $('body').on('change', '.list-left .course-group .course-group-checkbox,  .list-right .course-group .course-group-checkbox', function(){
        var self = $(this);
        toggleGroup(self);
  });

  $('.list-left .course-group  .list-group-item').click(function(){
      var slectedGroup = $(this).closest('.course-group');
      var selectedLists = $(this).closest('.list-group');
      var parentLi = selectedLists.parent('.list-group-item');
      var selectedGroupCheckBox = $(this).closest('.course-group').find('.course-group-link .course-group-checkbox');
      var isSelected = $(this).find('.list-group-item-link-check').is(':checked');
      if(isSelected){
          $(this).addClass('active');
          if(parentLi){
              parentLi.addClass('active');
          }
      } else {
          $(this).removeClass('active');
      }
  });

  $('body').on('click', '.selected-courses .list-group-item', function(){
      var isSelected = $(this).find('.list-group-item-link-check').is(':checked');
      if(isSelected){
          $(this).addClass('active');
          $('.move-left').removeClass('disabled');
      } else {
          $(this).removeClass('active');
      }
  });

  $('.course-selection').on('click', 'button', function() {
      var $button = $(this), actives = '', selectedList = '';
      if ($button.hasClass('move-left')) {
          moveCoursesLeft($button);
      } else if ($button.hasClass('move-right')) {
          moveCoursesRight($button);
      }
  });

  $('body').on('keyup', '.course-available__wrapper_search input, .selected-courses__wrapper_search input', function(event){
      var searchVal =  $.trim($(event.target).val());
      $(this).parent().next().find('.list-group li').filter(function(index, item){
          var labeltext = $(item).find('label').text().toLowerCase();
          if(labeltext.indexOf(searchVal) < 0){
              $(item).parent().parent().hide();
          } else {
              $(item).parent().parent().show();
          }
      });
  });

  function moveCoursesRight(button){
      $('.list-right .course-group ul').empty();
      $('.list-left .course-group>.list-group>.list-group-item').each(function(index, listItem){
          var self = $(listItem);
          var hasSelections = self.hasClass('active');
          if(hasSelections){
              var createListItem = $("<li class='list-group-item'>");
              var hasChildList = self.children('.list-group').clone(false);
              var groupTitle = self.children("*:not('.list-group')").clone(false);
              var selectedList = hasChildList.find('li').filter(function(index, listItem){
                  return $(listItem).hasClass('active');
              });
              hasChildList.empty();
              hasChildList.append(selectedList);
              createListItem.append(groupTitle);
              createListItem.append(hasChildList);
              if(hasChildList.children().length > 0){
                  createListItem.appendTo('.list-right .course-group>ul');
              }
              resetCourses('list-right');
              button.blur();
          }
      });
  }

  function moveCoursesLeft(button){
      var lists = $('.list-right .course-group>.list-group>.list-group-item');
      lists.each(function(index, listItem){
          var self = $(listItem);
          var hasSelections = self.hasClass('active');
          if(hasSelections){
              var hasChildList = self.children('.list-group');
              var subListLength = self.children('.list-group').children().length;
              if(subListLength <= 1){
                  self.remove();
              }
              hasChildList.find('li').each(function(index, listItem){
                  var activeList = $(listItem).hasClass('active');
                  if(activeList){
                      $(listItem).remove();
                  }
              });
          }
      });

  }

  function resetCourses(list) {
      $('.'+list).find('.course-group>.list-group>.list-group-item').each(function(index, listItem){
            $(listItem).find('input[type="checkbox"]').prop('checked', false);
            var hasChildList = $(listItem).children('.list-group');
            hasChildList.find('li').each(function(index, subList){
                $(subList).find('input[type="checkbox"]').prop('checked', false);
                $(subList).removeClass('active');
            });
      });
  }

  function toggleGroup(target){
      var isChecked = target.is(":checked");
      if(isChecked){
          target.closest('.list-group').find('li').each(function(index, listItem){
              $(listItem).addClass('active');
              $(listItem).find('input[type="checkbox"]').prop('checked', true);
          });
      } else {
        target.closest('.list-group').find('li').each(function(index, listItem){
            $(listItem).removeClass('active');
            $(listItem).find('input[type="checkbox"]').prop('checked', false);
        });
      }
  }

});
