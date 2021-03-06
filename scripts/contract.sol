pragma solidity >=0.4.21 <0.6.0;


contract coldchainShipment {

        struct Shipment {
                bytes32         shipmentId;
                string          productList;
                uint            blockTimestamp;
                string          fromUser;

                ShipmentDetails shipmentDetails;
                MessageType     msgType;
                ShipmentAlerts  shipmentAlerts;
        }

        struct ShipmentDetails {
                string                  sourceLocation;
                string                  destinationLocation;
                string                  logisticsPartner;
                bytes32                 dateOfShipment;
                bytes32                 dateOfDelivery;
                string                  purchaseOrderNumber;
        }

        struct MessageType {
                string                  messageType;
                string                  shipmentInfo;
                string                  status;
                string          docName;
                string                  docType;
                string                  docRef;
                string                  heartBeat;
        }

        struct ShipmentAlerts {
                int                             alertCount;
                string                  alertDetails;
        }


        mapping(bytes32 => Shipment)ShipmentList;
        bytes32[] shipmentAccts;
        uint16 shipmentCount  = 0;
        uint16 totalAlerts = 0;

        event ShipmentEvent(
                bytes32 indexed shipmentId,
                uint                    blockTimestamp,
                string                  productList,

                string                  messageType,
                string          fromUser
        );

        event ShipmentDetailsEvent(
                bytes32 indexed shipmentId,
                uint                    blockTimestamp,

                string                  sourceLocation,
                string                  destinationLocation,
                string                  logisticsPartner,
                bytes32                 dateOfShipment,
                bytes32                 dateOfDelivery,
                string                  purchaseOrderNumber,

                string                  messageType,
                string          fromUser
        );

        event MsgTypeDetailsEvent (
            bytes32 indexed shipmentId,
                uint                    blockTimestamp,

                string                  shipmentInfo,
                string                  status,
                string                  heartBeat,

                string                  messageType,
                string          fromUser
        );

        event ShipmentDocUploadEvent (
                bytes32 indexed shipmentId,
                uint                    blockTimestamp,

                string                  docName,
                string                  docType,
                string                  docRef,

                string                  messageType,
                string          fromUser
        );

        event ShipmentAlertsEvent (
                bytes32 indexed shipmentId,
                uint                    blockTimestamp,

                int                     alertCount,
                string                  alertDetails,

                string                  messageType,
                string          fromUser
        );


        function createShipment(bytes32 _shipmentId, string memory _productList,
                                                        string memory _sourceLocation, string memory _destinationLocation, string memory _logisticsPartner,
                                                        bytes32 _dateOfShipment, bytes32 _dateOfDelivery, string memory _purchaseOrderNumber,
                                                        string memory _messageType, string memory _fromUser
                                                        ) public
    {
        shipmentCount++;

        ShipmentList[_shipmentId].shipmentId                                            = _shipmentId;
        ShipmentList[_shipmentId].productList                                           = _productList;
        ShipmentList[_shipmentId].blockTimestamp                                        =  block.timestamp;

        ShipmentList[_shipmentId].shipmentDetails.sourceLocation                = _sourceLocation;
        ShipmentList[_shipmentId].shipmentDetails.destinationLocation   = _destinationLocation;
                ShipmentList[_shipmentId].shipmentDetails.logisticsPartner      = _logisticsPartner;
                ShipmentList[_shipmentId].shipmentDetails.dateOfShipment        = _dateOfShipment;
                ShipmentList[_shipmentId].shipmentDetails.dateOfDelivery        = _dateOfDelivery;
                ShipmentList[_shipmentId].shipmentDetails.purchaseOrderNumber   = _purchaseOrderNumber;
                ShipmentList[_shipmentId].msgType.messageType                                   = _messageType;
                ShipmentList[_shipmentId].fromUser                              = _fromUser;

        shipmentAccts.push((bytes32) (_shipmentId));
        emitShipmentEvent(_shipmentId);
                emitShipmentDetailsEvent(_shipmentId);
    }

        function getShipments() public view returns (bytes32[] memory){
        return shipmentAccts;
    }

    function getShipmentCount() public view returns (uint16) {
        return shipmentCount;
    }

    function getShipmentById (bytes32 _shipmentId) public view returns (bytes32, string memory) {

        return (
                        ShipmentList[_shipmentId].shipmentId,
                        ShipmentList[_shipmentId].productList
        );
    }

    function getShipmentDetails(bytes32 _shipmentId) public view returns (string memory, string memory, string memory, bytes32, bytes32, string memory){
        return (
                        ShipmentList[_shipmentId].shipmentDetails.sourceLocation,
                        ShipmentList[_shipmentId].shipmentDetails.destinationLocation,
                        ShipmentList[_shipmentId].shipmentDetails.logisticsPartner,
                        ShipmentList[_shipmentId].shipmentDetails.dateOfShipment,
                        ShipmentList[_shipmentId].shipmentDetails.dateOfDelivery,
                        ShipmentList[_shipmentId].shipmentDetails.purchaseOrderNumber
                );
    }

        function getMsgTypeDetails(bytes32 _shipmentId) public view returns (string memory, string memory, string memory, string memory, string memory, string memory){
        return (
                        ShipmentList[_shipmentId].msgType.shipmentInfo,
                        ShipmentList[_shipmentId].msgType.status,
                        ShipmentList[_shipmentId].msgType.docName,
                        ShipmentList[_shipmentId].msgType.docType,
                        ShipmentList[_shipmentId].msgType.docRef,
                        ShipmentList[_shipmentId].msgType.heartBeat
                );
    }

        function getShipmentAlerts(bytes32 _shipmentId) public view returns (int, string memory) {
                return (
                        ShipmentList[_shipmentId].shipmentAlerts.alertCount,
                        ShipmentList[_shipmentId].shipmentAlerts.alertDetails
                );
        }

        function updateShipmentInfo(bytes32 _shipmentId, string memory _shipmentInfo, string memory _messageType, string memory _fromUser) public {
        ShipmentList[_shipmentId].msgType.shipmentInfo                  = _shipmentInfo;
                ShipmentList[_shipmentId].blockTimestamp                        =  block.timestamp;
                ShipmentList[_shipmentId].msgType.messageType                   = _messageType;
                ShipmentList[_shipmentId].fromUser                      = _fromUser;
        emitMsgTypeDetailsEvent(_shipmentId);
    }

    function updateShipmentStatus(bytes32 _shipmentId, string memory _status, string memory _messageType, string memory _fromUser) public {
        ShipmentList[_shipmentId].msgType.status                                = _status;
                ShipmentList[_shipmentId].blockTimestamp                                =  block.timestamp;
                ShipmentList[_shipmentId].msgType.messageType                   = _messageType;
                ShipmentList[_shipmentId].fromUser                      = _fromUser;
        emitMsgTypeDetailsEvent(_shipmentId);
    }

    function updateShipmentDocs(bytes32 _shipmentId, string memory _docName, string memory _docType, string memory _docRef, string memory _messageType, string memory _fromUser) public {
        ShipmentList[_shipmentId].msgType.docName                               = _docName;
                ShipmentList[_shipmentId].msgType.docType                               = _docType;
                ShipmentList[_shipmentId].msgType.docRef                                = _docRef;
                ShipmentList[_shipmentId].blockTimestamp                                =  block.timestamp;
                ShipmentList[_shipmentId].msgType.messageType                   = _messageType;
                ShipmentList[_shipmentId].fromUser                      = _fromUser;
                emitShipmentDocUploadEvent(_shipmentId);
    }

    function updateShipmentHeartBeat(bytes32 _shipmentId, string memory _heartBeat, string memory _messageType, string memory _fromUser) public {
        ShipmentList[_shipmentId].msgType.heartBeat                     = _heartBeat;
                ShipmentList[_shipmentId].blockTimestamp                        =  block.timestamp;
                ShipmentList[_shipmentId].msgType.messageType                   = _messageType;
                ShipmentList[_shipmentId].fromUser                      = _fromUser;
        emitMsgTypeDetailsEvent(_shipmentId);
    }

        function updateShipmentAlerts(bytes32 _shipmentId, uint16 _alertCount, string memory _alertDetails, string memory _messageType, string memory _fromUser) public {
        totalAlerts += _alertCount;
                ShipmentList[_shipmentId].shipmentAlerts.alertCount     = totalAlerts;
                ShipmentList[_shipmentId].shipmentAlerts.alertDetails   = _alertDetails;
                ShipmentList[_shipmentId].blockTimestamp                        =  block.timestamp;
                ShipmentList[_shipmentId].msgType.messageType                   = _messageType;
                ShipmentList[_shipmentId].fromUser                      = _fromUser;
        emitShipmentAlertsEvent(_shipmentId);
    }


        function emitShipmentEvent(bytes32 _shipmentId) public
    {
                emit ShipmentEvent (
                        _shipmentId,
                        ShipmentList[_shipmentId].blockTimestamp,
                        ShipmentList[_shipmentId].productList,
                        ShipmentList[_shipmentId].msgType.messageType,
                        ShipmentList[_shipmentId].fromUser
                );
    }

        function emitShipmentDetailsEvent(bytes32 _shipmentId) public
    {
                emit ShipmentDetailsEvent (
                        _shipmentId,
                        ShipmentList[_shipmentId].blockTimestamp,

                        ShipmentList[_shipmentId].shipmentDetails.sourceLocation,
                        ShipmentList[_shipmentId].shipmentDetails.destinationLocation,
                        ShipmentList[_shipmentId].shipmentDetails.logisticsPartner,
                        ShipmentList[_shipmentId].shipmentDetails.dateOfShipment,
                        ShipmentList[_shipmentId].shipmentDetails.dateOfDelivery,
                        ShipmentList[_shipmentId].shipmentDetails.purchaseOrderNumber,
                        ShipmentList[_shipmentId].msgType.messageType,
                        ShipmentList[_shipmentId].fromUser
                );
    }

        function emitMsgTypeDetailsEvent(bytes32 _shipmentId) public
        {
                emit MsgTypeDetailsEvent (
                    _shipmentId,
                        ShipmentList[_shipmentId].blockTimestamp,
                        ShipmentList[_shipmentId].msgType.shipmentInfo,
                        ShipmentList[_shipmentId].msgType.status,
                        ShipmentList[_shipmentId].msgType.heartBeat,
                        ShipmentList[_shipmentId].msgType.messageType,
                        ShipmentList[_shipmentId].fromUser
                );
        }

        function emitShipmentDocUploadEvent(bytes32 _shipmentId) public
        {
                emit ShipmentDocUploadEvent(
                        _shipmentId,
                        ShipmentList[_shipmentId].blockTimestamp,
                        ShipmentList[_shipmentId].msgType.docName,
                        ShipmentList[_shipmentId].msgType.docType,
                        ShipmentList[_shipmentId].msgType.docRef,
                        ShipmentList[_shipmentId].msgType.messageType,
                        ShipmentList[_shipmentId].fromUser
                );
        }

        function emitShipmentAlertsEvent(bytes32 _shipmentId) public
        {
                emit ShipmentAlertsEvent(
                        _shipmentId,
                        ShipmentList[_shipmentId].blockTimestamp,
                        ShipmentList[_shipmentId].shipmentAlerts.alertCount,
                        ShipmentList[_shipmentId].shipmentAlerts.alertDetails,
                        ShipmentList[_shipmentId].msgType.messageType,
                        ShipmentList[_shipmentId].fromUser
                );
        }

}