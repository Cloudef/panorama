import QtQuick 1.1
import "util.js" as Utils

View {
  id: view
  viewTitle: "Home"
  property QtObject pndManager

  property variant lists: [lastUpdated, highestRated]
  property int currentIndex: 0
  Keys.onUpPressed: lists[currentIndex].currentIndex = Math.max(lists[currentIndex].currentIndex - 1, 0)
  Keys.onDownPressed: lists[currentIndex].currentIndex = Math.min(lists[currentIndex].currentIndex + 1, lists[currentIndex].count - 1)
  Keys.onLeftPressed: currentIndex = Math.max(currentIndex - 1, 0)
  Keys.onRightPressed: currentIndex = Math.min(currentIndex + 1, lists.length - 1)
  onOkButton: openCurrent()

  Component { id: packageView; PackageView {} }

  Component.onCompleted: {
    for(var i = 0; i < lists.length; ++i) {
      lists[i].listIndex = i;
    }
  }

  function openCurrent() {
    var list = lists[currentIndex]
    if(list.currentIndex < list.count)
    var view = stack.push(packageView, {
                            "pnd": list.model[list.currentIndex],
                            "viewTitle": list.model[list.currentIndex].title,
                            "pndManager": pndManager
                          });
  }

  Item {
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.horizontalCenter
    anchors.bottom: parent.bottom

    Image {
      id: lastUpdatedIcon
      source: "img/upload_24x32.png"
      sourceSize {
        height: 32
        width: 32
      }
      height: 32
      width: 32
      fillMode: Image.PreserveAspectFit
      anchors.top: parent.top
      anchors.left: parent.left
      anchors.margins: 16
    }

    Text {
      id: lastUpdatedText
      text: "Last updated"
      anchors.left: lastUpdatedIcon.right
      anchors.right: parent.right
      anchors.top: parent.top
      anchors.margins: 16
      font.pixelSize: 32
    }

    StyledListView {
      id: lastUpdated
      anchors.top: lastUpdatedText.bottom
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.bottom: parent.bottom
      anchors.margins: 16
      spacing: 8

      property int listIndex
      property bool active: listIndex === view.currentIndex

      function refresh() { model = pndManager.packages.sortedByLastUpdated().all() }

      Connections {
        target: pndManager
        onPackagesChanged: lastUpdated.refresh()
      }

      highlight: Rectangle {
        width: lastUpdated.width
        height: 48
        color: "#ddd"
        radius: 8
        x: lastUpdated.currentItem.x
        y: lastUpdated.currentItem.y
        visible: lastUpdated.active
      }

      highlightFollowsCurrentItem: false

      delegate: PackageDelegate {
        pnd: modelData
        height: 48
        width: lastUpdated.width

        onClicked: {
          view.currentIndex = lastUpdated.listIndex;
          lastUpdated.currentIndex = index;
          view.openCurrent();
        }

        Text {
          text: Utils.prettyLastUpdatedString(modelData.modified)
          font.pixelSize: 14
        }
      }
    }
  }

  Item {
    anchors.top: parent.top
    anchors.left: parent.horizontalCenter
    anchors.right: parent.right
    anchors.bottom: parent.bottom

    Image {
      id: highestRatedIcon
      source: "img/star_32x32.png"
      sourceSize {
        height: 32
        width: 32
      }
      height: 32
      width: 32
      fillMode: Image.PreserveAspectFit
      anchors.top: parent.top
      anchors.left: parent.left
      anchors.margins: 16
    }

    Text {
      id: highestRatedText
      text: "Highest rated"
      anchors.left: highestRatedIcon.right
      anchors.right: parent.right
      anchors.top: parent.top
      anchors.margins: 16
      font.pixelSize: 32
    }

    StyledListView {
      id: highestRated
      anchors.top: highestRatedText.bottom
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.bottom: parent.bottom
      anchors.margins: 16
      spacing: 8

      property int listIndex
      property bool active: listIndex === view.currentIndex

      function refresh() { model = pndManager.packages.sortedByRating().all() }

      Connections {
        target: pndManager
        onPackagesChanged: highestRated.refresh()
      }

      highlight: Rectangle {
        width: highestRated.width
        height: 48
        color: "#ddd"
        radius: 8
        x: highestRated.currentItem.x
        y: highestRated.currentItem.y
        visible: highestRated.active
      }

      highlightFollowsCurrentItem: false

      delegate: PackageDelegate {
        pnd: modelData
        height: 48
        width: highestRated.width

        onClicked: {
          view.currentIndex = highestRated.listIndex;
          highestRated.currentIndex = index;
          view.openCurrent();
        }

        Text {
          function getRating() {
            var s = "";
            for(var i = 0; i < Math.ceil(pnd.rating/20); ++i) {
              s += "★";
            }
            return s;
          }

          text: pnd.rating !== 0 ? getRating() : "(not rated)"
          font.pixelSize: 14
        }
      }
    }
  }
}
