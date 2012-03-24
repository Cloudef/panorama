import QtQuick 1.1

View {
  viewTitle: "Search"

  property QtObject pndManager

  Keys.forwardTo: packageList
  onOkButton: packageList.openCurrent()

  Rectangle {
    id: searchContainer
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: parent.top
    height: 64
    color: "#eee"

    Rectangle {
      id: searchBox
      color: "#fff"
      border.color:  "#ccc"
      border.width: 1
      radius: 8
      height: 32
      anchors.top: parent.top
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.margins: 16

      Image {
        id: searchIcon
        source: "img/magnifying_glass_32x32.png"
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.margins: 4
        fillMode: Image.PreserveAspectFit
        smooth: true
      }

      TextInput {
        id: search
        anchors.left: searchIcon.right
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.margins: 4
        font.pixelSize: 20
        activeFocusOnPress: false
        onAccepted: {
          packageList.model = pndManager.searchPackages(text).sortedByTitle().all()
          noSearchResultsText.visible = packageList.count === 0
        }
      }
    }

    Rectangle {
      height: 1
      color: "#ccc"
      anchors.bottom: parent.bottom
      anchors.left: parent.left
      anchors.right: parent.right
    }

  }

  PackageList {
    id: packageList
    anchors.top: searchContainer.bottom
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    columns: 2
    clip: true
    model: null
    Keys.priority: Keys.AfterItem
    Keys.forwardTo: [ui, search]

    delegate: PackageDelegate {
      pnd: modelData
      height: packageList.cellHeight
      width: packageList.cellWidth

      onClicked: {
        packageList.currentIndex = index;
        packageList.openCurrent();
      }

      Text {
        id: categoriesText
        property variant categories: modelData.categories
        function getCategories() {
          var result = [];
          for(var i = 0; i < categories.length; ++i) {
            if(result.indexOf(categories[i].main) === -1) {
              result.push(categories[i].main);
            }
            result.push(categories[i].sub);
          }

          return result.join(", ");
        }

        text: getCategories()
        font.pixelSize: 14
      }

      Text {
        id: authorText
        anchors.top: categoriesText.bottom
        text: modelData.author.name
        font.pixelSize: 14
      }

      Text {
        function getRating() {
          var s = "";
          for(var i = 0; i < Math.ceil(pnd.rating/20); ++i) {
            s += "★";
          }
          return s;
        }

        text: getRating()
        visible: pnd.rating !== 0
        font.pixelSize: 14

        anchors.top: categoriesText.bottom
        anchors.right: parent.right
        anchors.rightMargin: 32
      }

      Image {
        source: "img/download_darkgrey_24x32.png"
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.margins: 8
        height: 16
        width: 16
        fillMode: Image.PreserveAspectFit
        visible: modelData.installed
      }
    }

    Text {
      id: noSearchResultsText
      text: "No search results"
      font.pixelSize: 20
      anchors.centerIn: parent
      visible: false
    }

  }

}

