﻿<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="X-UA-Compatible" content="IE=edge" >
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" >
        <title>전자현황판 자료입력</title>
        <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=10, user-scalable=yes"/>

        <link rel="stylesheet" type="text/css" href="/extjs/packages/ext-theme-crisp-touch/build/resources/ext-theme-crisp-touch-all.css" />
        <script type="text/javascript" src="/extjs/ext-all.js"></script>
        <script type="text/javascript" src="/extjs/common.js"></script>
        <link rel="stylesheet" type="text/css" href="/extjs/css/new2015.css">

    </head>

<script>
Ext.KeyNav.forceKeyDown = true;

var commonCols = 
[
" ",
"TITLE" , 
"INPUT_TYPE" , 
"UNIT" , 
"CODE" , 
"DIVISION" , 
"OWNER" , 
"ATTR1" ,
"ATTR2" ,
"ATTR4" ,
"INPUT_CYCLE" , 
"INPUT_CYCLE2" , 
"YEAR" , 
"MONTH" , 
"YEAR" , 
"VAL_YEAR_01" , 
"VAL_MONTH_01" , 
"VAL_MONTH_02" , 
"VAL_MONTH_03" , 
"VAL_MONTH_04" , 
"VAL_MONTH_05" , 
"VAL_MONTH_06" , 
"VAL_MONTH_07" , 
"VAL_MONTH_08" , 
"VAL_MONTH_09" , 
"VAL_MONTH_10" , 
"VAL_MONTH_11" , 
"VAL_MONTH_12" , 
"YEAR" , 
"MONTH" , 
"VAL_WEEK_01" , 
"VAL_WEEK_02" , 
"VAL_WEEK_03" , 
"VAL_WEEK_04" , 
"VAL_WEEK_05" , 
"ATTR3" ];


Ext.define('Ext.patch.EXTJS16166', {
    override: 'Ext.view.View',
    compatibility: '5.1.0.107',
    handleEvent: function(e) {
        var me = this,
            isKeyEvent = me.keyEventRe.test(e.type),
            nm = me.getNavigationModel();

        e.view = me;
        
        if (isKeyEvent) {
            e.item = nm.getItem();
            e.record = nm.getRecord();
        }

        // If the key event was fired programatically, it will not have triggered the focus
        // so the NavigationModel will not have this information.
        if (!e.item) {
            e.item = e.getTarget(me.itemSelector);
        }
        if (e.item && !e.record) {
            e.record = me.getRecord(e.item);
        }

        if (me.processUIEvent(e) !== false) {
            me.processSpecialEvent(e);
        }
        
        // We need to prevent default action on navigation keys
        // that can cause View element scroll unless the event is from an input field.
        // We MUST prevent browser's default action on SPACE which is to focus the event's target element.
        // Focusing causes the browser to attempt to scroll the element into view.
        
        if (isKeyEvent && !Ext.fly(e.target).isInputField()) {
            if (e.getKey() === e.SPACE || e.isNavKeyPress(true)) {
                e.preventDefault();
            }
        }
    }
});


/* 
 * 공통으로 사용하기 위한 코드들을 모아놓은곳이라 보면 된다..
 * 일단은 쿠키 처리를 위하여 wiseman에서 사용되던 소스를 일부 가져왔다..
 */

var theme;  
var select_tree_id = "";  
var select_tree_record = null;  



//--------------------------- 일단은 선을 긋고..............................
//-------- 분류체계 조회/추가/삭제/변경 까지 확인...........................

var lastPath = getCookie( 'CLS_TREE'  );

function _parseInt( val ){
    try{
        if( val == null || val == '' ) return 0;
        return parseInt( val );
    }catch(e){
        return 0;
    }
}

function reload_tree() {
    tree.getStore().load();
    var path = getCookie( 'CLS_TREE'  );
    tree.expandPath( lastPath );
    tree.selectPath( lastPath );

}

var tree_store = Ext.create('Ext.data.TreeStore', {
		fields: ['text','id','order', 'OBJECT_ID','CLASSIFICATION_CODE' ],
		proxy:{type:'ajax',url: '/Process.aspx?action=GetList',reader:{type:'json',root: 'links' }, extraParams: { 'PATH' : lastPath, 'fullload' : this.fullload , 'type': this.targettype, 'checked' : this.checked, 'displayvalue' : this.displayvalue,'displaycode' : this.displaycode,'displaysort' : this.displaysort } },
		root:{text:this.rootTitle,id:this.rootID, order:'0'},
		folderSort: true,
		sorters: [{property: 'order',direction: 'ASC'}]
	});

function action_cls_insert( btn,text )
{
    if( btn == 'ok' )
    {
        if( text == null || text == '' ) { alert('입력을 확인해 주십시오'); return; }

        if( select_tree_record == null )
        {
            var record = tree.getRootNode().findChild('id',select_tree_id,true);
            select_tree_record = record.data;
        }

        Ext.Ajax.request({
            url:'/Process.aspx?action=ClsIns',
            params: { 'OBJECT_ID' : select_tree_record.OBJECT_ID , 'CATE_NAME' : text },
	        method:'GET',
	        success:function( result, request ){
                var jsonData = Ext.JSON.decode(result.responseText);
                var res = jsonData.RESULT;
	            if( res == 'true' )
                {
                    alert('성공하였습니다.');
                    reload_tree();
                }else{
                    alert('실패하였습니다.');
                }
            },
	        failure:function(result,request){
	            alert( '실패하였습니다. 결과를 확인해 주십시오.' );
            }
        });
        return;
    }
}
function action_cls_delete ( btn )
{
    if( btn == 'yes' )  
    {
        if( select_tree_record == null )
        {
            var record = tree.getRootNode().findChild('id',select_tree_id,true);
            select_tree_record = record.data;
        }

        Ext.Ajax.request({
            url:'/Process.aspx?action=ClsDel',
            params: { 'OBJECT_ID' : select_tree_record.OBJECT_ID },
	        method:'GET',
	        success:function( result, request ){
                var jsonData = Ext.JSON.decode(result.responseText);
                var res = jsonData.RESULT;
	            if( res == 'true' )
                {
                    alert('성공하였습니다.');
                    reload_tree();
                }else{
                    alert('실패하였습니다.');
                }
            },
	        failure:function(result,request){
	            alert( '실패하였습니다. 결과를 확인해 주십시오.' );
            }
        });
    }
}
function action_cls_modify( btn, text )
{
    if( btn == 'ok' )
    {
        if( text == null || text == '' ) { alert('입력을 확인해 주십시오'); return; }

        if( select_tree_record == null )
        {
            var record = tree.getRootNode().findChild('id',select_tree_id,true);
            select_tree_record = record.data;
        }

        Ext.Ajax.request({
            url:'/Process.aspx?action=ClsMod',
            params: { 'OBJECT_ID' : select_tree_record.OBJECT_ID , 'CATE_NAME' : text },
	        method:'GET',
	        success:function( result, request ){
                var jsonData = Ext.JSON.decode(result.responseText);
                var res = jsonData.RESULT;
	            if( res == 'true' )
                {
                    alert('성공하였습니다.');
                    reload_tree();
                }else{
                    alert('실패하였습니다.');
                }
            },
	        failure:function(result,request){
	            alert( '실패하였습니다. 결과를 확인해 주십시오.' );
            }
        });
        return;
    }
}   

var initComplete = false;

var tree = new Ext.tree.TreePanel({ 
		//layout: 'anchor', <-- 요걸로 하면 스크롤바가.. ㅜ.ㅜ
		animate: false,
		border : false,
		rootVisible: false,
		frame: true,
        scrollable: true,
        region: 'center',
		store : tree_store,
        
        tbar  : new Ext.Toolbar({
            cls:'top-toolbar',
            items:[,{
                text:'Add',
                tooltip: 'Expand All',
                handler: function(){ 
                    if( select_tree_id != null ){
                        Ext.MessageBox.prompt('확인', '신규 분류 명칭을 입력해주십시오', action_cls_insert );
                    } }
                },{
                text:'Mod',
                tooltip: 'Expand All',
                handler: function(){ 
                    if( select_tree_id != null ){
                        Ext.MessageBox.prompt('확인', '변경될 분류 명칭을 입력해주십시오', action_cls_modify );
                    } }
                },{
                text:'Del',
                tooltip: 'Expand All',
                handler: function(){ 
                    if( select_tree_id != null ){
                        Ext.MessageBox.confirm('확인', '해당 분류를 삭제 하시겠습니까?', action_cls_delete );
                    } }
                }
            ]
        }),
//	height:500,
        autoHeight:true,
        anchor:'100% 100%',
        viewConfig: {

	    autoScroll: true, 
            stripeRows: true,
//            forceFit: true,
            style : { overflow: 'auto' }
        }
	});  

    var saveCookie = function( record ){
		var oids = record.getPath();

		setCookieLT( 'CLS_TREE', oids, 604800, '/');
	}

    tree.on( 'itemclick', function( obj , record, item ) { select_tree_id = record.data.id; select_tree_record = record.data; saveCookie( record ); reloadList( record.data.CLASSIFICATION_CODE ) }, this );
    
//------------------------------------------------------


function renderNormal( value )
{
    //return '<div style="white-space:normal; !important;">' + value + ' </div>';
    //Ext.util.Format.numberRenderer(value,'0.000');
return value;
}

Ext.util.Format.thousandSeparator = ',';
Ext.util.Format.decimalSeparator = '.';

function renderNumber( value )
{
    if( value == null ) return '';
    try{
	if( value.indexOf( '.' ) >= 0 )
	    return Ext.util.Format.number(value, '0,000.00');
	return Ext.util.Format.number(value, '0,000');
    }catch(e){
	return value;
    }
}
 

Ext.define('OBJECT', {
        extend: 'Ext.data.Model',
        fields: [
{name: 'OBJECT_ID', type: 'integer'},
{name: 'CREATOR_ID', type: 'integer'},
{name: 'UPDATE_DATE', type: 'integer'},
{name: 'UPDATOR_ID' },
{name: 'No'},
{name: 'UNIT'},
{name: 'INPUT_TYPE'},
{name: 'TITLE',type: 'string'},
{name: 'CODE'},
{name: 'INPUT_CYCLE'},{name: 'INPUT_CYCLE2'},
{name: 'DIVISION'},
{name: 'YEAR'},{name: 'MONTH'},
{name: 'YEAR_VALUE'},{name: 'VALUE_HALF_01'},{name: 'VALUE_HALF_02'},
{name: 'VAL_QTR_01'},{name: 'VAL_QTR_02'},{name: 'VAL_QTR_03'},{name: 'VAL_QTR_04'},
{name: 'VAL_MONTH_01'},{name: 'VAL_MONTH_02'},{name: 'VAL_MONTH_03'},{name: 'VAL_MONTH_04'},{name: 'VAL_MONTH_05'},{name: 'VAL_MONTH_06'},
{name: 'VAL_MONTH_07'},{name: 'VAL_MONTH_08'},{name: 'VAL_MONTH_09'},{name: 'VAL_MONTH_10'},{name: 'VAL_MONTH_11'},{name: 'VAL_MONTH_12'},
{name: 'VAL_WEEK_01'},{name: 'VAL_WEEK_02'},{name: 'VAL_WEEK_03'},{name: 'VAL_WEEK_04'},{name: 'VAL_WEEK_05'},
{name: 'VAL_DAY_01'},{name: 'VAL_DAY_02'},{name: 'VAL_DAY_03'},{name: 'VAL_DAY_04'},{name: 'VAL_DAY_05'},{name: 'VAL_DAY_06'},{name: 'VAL_DAY_07'},{name: 'VAL_DAY_08'},{name: 'VAL_DAY_09'},{name: 'VAL_DAY_10'},
{name: 'VAL_DAY_11'},{name: 'VAL_DAY_12'},{name: 'VAL_DAY_13'},{name: 'VAL_DAY_14'},{name: 'VAL_DAY_15'},{name: 'VAL_DAY_16'},{name: 'VAL_DAY_17'},{name: 'VAL_DAY_18'},{name: 'VAL_DAY_19'},{name: 'VAL_DAY_20'},
{name: 'VAL_DAY_21'},{name: 'VAL_DAY_22'},{name: 'VAL_DAY_23'},{name: 'VAL_DAY_24'},{name: 'VAL_DAY_25'},{name: 'VAL_DAY_26'},{name: 'VAL_DAY_27'},{name: 'VAL_DAY_28'},{name: 'VAL_DAY_29'},{name: 'VAL_DAY_30'},{name: 'VAL_DAY_31'},
{name: 'ATTR1', type:'bool' },{name: 'ATTR2', type:'bool' },{name: 'ATTR3'},{name: 'ATTR4', type:'bool' }
        ]
    });

function getDefaultOBJECT(){
    return Ext.create('OBJECT', { 'OBJECT_ID' : '', 'No':'', 'YEAR':'2016' });
}

var store = Ext.create('Ext.data.Store', {
        model: 'OBJECT',
		proxy:{ type:'ajax',url: '/Process.aspx?action=GetOBJList',
                reader:'json'
        },
        autoLoad: true,
	});

var selectIdx = -1;
var cellEditing = Ext.create('Ext.grid.plugin.CellEditing', {
        clicksToEdit: 1,
        listeners: { 
            beforeedit: function (obj, obj2, obj3) {
                if( obj2.field.indexOf( 'ATTR3' ) >= 0 )
                {
                    var ownercode = obj2.store.data.getAt( obj2.rowIdx ).data.OWNER;
                    STORE_PERSON.filter( "filter", ownercode );
                }
                if( obj2.field.indexOf( 'VAL_' ) >= 0 )
                    selectIdx = obj2.colIdx;
                else
                    selectIdx = -1;
            }
        }
    });

// 기본 세트는 다음과 같다.. STORE, COMBO, RENDERER
//---- 사업부............
var STORE_DIV = Ext.create( 'Ext.data.Store', { fields: ['view','value'],
                proxy:{type:'ajax',url: '/Process.aspx?action=getcodelist&code=code4',reader:{type:'json', root: 'users' }  }
//	data: [ { 'view': '공통',  'value': 'C' },
//	        { 'view': '철차',  'value': 'R' },
//	        { 'view': '중기',  'value': 'T' },
//	        { 'view': '플랜트','value': 'P' }
//    ]
});
STORE_DIV.load( { callback: store_callback } );
var COMBO_DIV = new Ext.form.field.ComboBox({
                displayField: 'view',
                valueField: 'value',
                queryMode: 'local',
                typeAhead: true,
                forceSelection:true,
                triggerAction: 'all',
                selectOnTab: true,
                store: STORE_DIV,
                lazyRender: true,
                allowBlank : false,
                listClass: 'x-combo-list-small'
            });
function renderDIV( value )
{
    index = STORE_DIV.findExact('value',value); 
    if (index != -1){
        return STORE_DIV.getAt(index).data.view; 
    }
    return value;
}

// 입력주기.....
var STORE_CYCLE = Ext.create( 'Ext.data.Store', { fields: ['view','value'],
    proxy:{type:'ajax',url: '/Process.aspx?action=getcodelist&code=code3',reader:{type:'json', root: 'users' }  }
//	data: [ { 'view': '년간',  'value': '1' },
//	        { 'view': '반기',  'value': '2' },
//	        { 'view': '분기',  'value': '3' },
//            { 'view': '월간',  'value': '4' },
//            { 'view': '주간',  'value': '5' },
//	        { 'view': '일간',  'value': '6' }
//	         ]
});
STORE_CYCLE.load( { callback: store_callback } );

var COMBO_CYCLE = new Ext.form.field.ComboBox({
                displayField: 'view',
                valueField: 'value',
                queryMode: 'local',
                typeAhead: true,
                forceSelection:true,
                triggerAction: 'all',
                selectOnTab: true,
                store: STORE_CYCLE,
                lazyRender: true,
                allowBlank : false,
                listClass: 'x-combo-list-small'
            });
function renderCYCLE( value )
{
    index = STORE_CYCLE.findExact('value',value); 
    if (index != -1){
        return STORE_CYCLE.getAt(index).data.view; 
    }
    return value;
}

//

// 입력주기2..
var STORE_CYCLE2 = Ext.create( 'Ext.data.Store', { fields: ['view','value'],
    proxy:{type:'ajax',url: '/Process.aspx?action=getcodelist&code=code3',reader:{type:'json', root: 'users' }  }
    });
STORE_CYCLE2.load( { callback: store_callback } );

var COMBO_CYCLE2 = new Ext.form.field.ComboBox({
                displayField: 'view',
                valueField: 'value',
                queryMode: 'local',
                typeAhead: true,
                forceSelection:true,
                triggerAction: 'all',
                selectOnTab: true,
                store: STORE_CYCLE2,
                lazyRender: true,
                allowBlank : false,
                listClass: 'x-combo-list-small'
            });
function renderCYCLE2( value )
{
    index = STORE_CYCLE2.findExact('value',value); 
    if (index != -1){
        return STORE_CYCLE2.getAt(index).data.view; 
    }
    return value;
}



// 입력유형.....
var STORE_INPUT = Ext.create( 'Ext.data.Store', { fields: ['view','value'],
    //autoLoad: true,      
    proxy:{type:'ajax',url: '/Process.aspx?action=getcodelist&code=code1',reader:{type:'json', root: 'users' }  }

//	data: [ { 'view': '계획',  'value': 'P' },
//	        { 'view': '실적',  'value': 'S' }
//	         ]
});

STORE_INPUT.load( { callback: store_callback } );




var COMBO_INPUT = new Ext.form.field.ComboBox({
                displayField: 'view',
                valueField: 'value',
                queryMode: 'local',
                typeAhead: true,
                forceSelection:true,
                triggerAction: 'all',
                selectOnTab: true,
                store: STORE_INPUT,
                //lazyRender: true,
                //allowBlank : false,
                listClass: 'x-combo-list-small'
            });
function renderINPUT( value )
{
    index = STORE_INPUT.findExact('value',value); 
    if (index != -1){
        return STORE_INPUT.getAt(index).data.view; 
    }
    return value;
}


// 부서선택
var STORE_DEPT = Ext.create( 'Ext.data.Store', { fields: ['view','value'],
    //autoLoad: true,      
    proxy:{type:'ajax',url: '/Process.aspx?action=getcodelist&code=dept',reader:{type:'json', root: 'users' }  }
});

STORE_DEPT.load( { callback: store_callback } );

var COMBO_DEPT = new Ext.form.field.ComboBox({
                displayField: 'view',
                valueField: 'value',
                queryMode: 'local',
                typeAhead: true,
                triggerAction: 'all',
                selectOnTab: true,
                forceSelection:true,
                store: STORE_DEPT,
                //lazyRender: true,
                allowBlank : false,
                listClass: 'x-combo-list-small'
            });
function renderDEPT( value )
{
    index = STORE_DEPT.findExact('value',value); 
    if (index != -1){
        return STORE_DEPT.getAt(index).data.view; 
    }
    return value;
}
//

// 입력유형.....
var STORE_UNIT= Ext.create( 'Ext.data.Store', { fields: ['view','value'],
    proxy:{type:'ajax',url: '/Process.aspx?action=getcodelist&code=code2',reader:{type:'json', root: 'users' }  }
//	data: [ { 'view': '원',  'value': '1' },
//            { 'view': '억',  'value': '2' },
//            { 'view': '%',  '   value': '3' },
//	        { 'view': '건',  'value': '4' }
//	         ]
});
STORE_UNIT.load( { callback: store_callback } );

var COMBO_UNIT = new Ext.form.field.ComboBox({
                displayField: 'view',
                valueField: 'value',
                queryMode: 'local',
                typeAhead: true,
                triggerAction: 'all',
                selectOnTab: true,
                store: STORE_UNIT,
                lazyRender: true,
                allowBlank : false,
                listClass: 'x-combo-list-small'
            });
function renderUNIT( value )
{
    index = STORE_UNIT.findExact('value',value); 
    if (index != -1){
        return STORE_UNIT.getAt(index).data.view; 
    }
    return value;
}



// 사용자선택
var STORE_PERSON= Ext.create( 'Ext.data.Store', { fields: ['view','value'],
    proxy:{type:'ajax',url: '/Process.aspx?action=getperson&code=person',reader:{type:'json', root: 'users' }  }
});
var COMBO_PERSON = new Ext.form.field.ComboBox({
                displayField: 'view',
                valueField: 'value',
                queryMode: 'local',
                typeAhead: true,
                triggerAction: 'all',
                selectOnTab: true,
                forceSelection:true,
                store: STORE_PERSON,
                allowBlank : false,
                listClass: 'x-combo-list-small'
            });
STORE_PERSON.load( { callback: store_callback } );

function renderPERSON( value )
{
    index = STORE_PERSON.findExact('value',value); 
    if (index != -1){
        return STORE_PERSON.getAt(index).data.view; 
    }
    return value;
}
function renderDATE( value )
{
    if( value != null ) {
        value = value.toString();
        return ( value.substring( 0, 4 ) + "/" +  value.substring( 4, 6 ) + "/" + value.substring( 6, 8 ) + " " + value.substring( 8, 10 ) + ":" + value.substring( 10, 12 ) );
    }

    return value;
}

//

var grid;
 
Ext.onReady(function(){
isTouchTheme = Ext.themeName === 'crisp-touch';


    var grid_toolbar;

    grid = Ext.create('Ext.grid.Panel', {
        //title: '관리항목',
        store: store,
        multiSelect : true,
        columnLines: true,
        enableColumnMove : false,
        plugins: [cellEditing],
        columns: { 
            defaults: { menuDisabled:true , autoRender : true,  sortable : true, 
                       align : 'center', style: 'text-align:center', renderer : renderNormal },
            items: 
        [{
            text     : ' ',
            locked   : true,
            width    : 30,
            sortable : false,
//sortable:false // menu shows but no sort options
//hideable:false // menu shows but column name not shown in columns menu
            dataIndex: 'No'
        },
        { 
            text     : '관리명칭',
            locked   : true,
            width    : 200,
            align    : 'left',
            dataIndex: 'TITLE',
            editor: {
                allowBlank: false
            }
        },
        {
            text     : '유형',
            locked   : true,
            width    : 40,
            align    : 'left',
            renderer : renderINPUT,
            dataIndex: 'INPUT_TYPE',
            editor: COMBO_INPUT
        },
        {
            text     : '지표ID',
            width    : 80,
            dataIndex: 'CODE',
            editor: {
                allowBlank: false
            }
        },
        {
            text     : '사업부',
            width    : 60,
            renderer : renderDIV,
            dataIndex: 'DIVISION',
            editor: COMBO_DIV
        },
        {
            text     : '주관부서',
            width    : 150,
            align    : 'left',
            renderer : renderDEPT,
            dataIndex: 'OWNER',
            editor: COMBO_DEPT
        },
        {
            text: '추가속성',
            columns: [
                { 
                    xtype: 'checkcolumn', 
                    text     : '누계', width    : 80, dataIndex: 'ATTR1' },
                { 
                    xtype: 'checkcolumn', 
                    text     : '추정',width    : 80, dataIndex: 'ATTR4'  }
            ]
        },
        {
            text     : '단위',
            locked   : true,
            width    : 80,
            align    : 'center',
            renderer : renderUNIT,
            dataIndex: 'UNIT',
            editor: COMBO_UNIT
        },
        {
            text: '입력주기',
            columns: [
                {id       : 'COL_INPUT_CYCLE1',text: '목표',align:'center',width    : 60,dataIndex: 'INPUT_CYCLE',renderer : renderCYCLE, dataIndex: 'INPUT_CYCLE', editor: COMBO_CYCLE },
                {id       : 'COL_INPUT_CYCLE2',text: '실적',align:'center',width    : 60,dataIndex: 'INPUT_CYCLE2',renderer : renderCYCLE2, dataIndex: 'INPUT_CYCLE2', editor: COMBO_CYCLE2 },
            ]
        },
        {
                text     : '기준년',
                width    : 80,
                dataIndex: 'YEAR',
                align    : 'right',
                editor: {
                    allowBlank: false
                }
        },
        {
                text     : '기준월',
                width    : 80,
                dataIndex: 'MONTH',
                align    : 'right',
                editor: {
                    allowBlank: false
                }
        },

        {
            text: '년간',
            columns: [
                {id       : 'COL_YEAR_Y',text     : '기준년',width    : 80,dataIndex: 'YEAR',align    : 'right',editor: {allowBlank: false}},
                {text     : '목표/실적',id       : 'COL_YEAR_1',width    : 60,dataIndex: 'VAL_YEAR_01', align:'right',renderer: renderNumber, editor: {allowBlank: false}}
            ]
        },
/*        {
            text: '반기',
            columns: [
                {id       : 'COL_HALF_Y',text     : '기준년',width    : 80,dataIndex: 'YEAR',align    : 'right',editor: {allowBlank: false}},
                {id       : 'COL_HALF_1',text     : '상반기',width    : 60,align    : 'right',dataIndex: 'VALUE_HALF_01',editor: {allowBlank: false}}, 
                {id       : 'COL_HALF_2',text     : '상반기',width    : 60,align    : 'right',dataIndex: 'VALUE_HALF_02',editor: {allowBlank: false}}
            ]
        },
*/
/*        {
            text: '분기',
            columns: [
                {id       : 'COL_QTR_Y',text     : '기준년',width    : 80,dataIndex: 'YEAR',align    : 'right',editor: {allowBlank: false}},
                {id       : 'COL_QTR_1',text     : '1분기',width    : 60,align    : 'right',dataIndex: 'VAL_QTR_01',editor: {allowBlank: false}}, 
                {id       : 'COL_QTR_2',text     : '2분기',width    : 60,align    : 'right',dataIndex: 'VAL_QTR_02',editor: {allowBlank: false}}, 
                {id       : 'COL_QTR_3',text     : '3분기',width    : 60,align    : 'right',dataIndex: 'VAL_QTR_03',editor: {allowBlank: false}}, 
                {id       : 'COL_QTR_4',text     : '4분기',width    : 60,align    : 'right',dataIndex: 'VAL_QTR_04',editor: {allowBlank: false}}
            ]
        },
*/
{
            text: '월간',
            columns: [
//                {id       : 'COL_MONTH_Y' ,text     : '기준년',width    : 80,dataIndex: 'YEAR',align    : 'right',editor: {allowBlank: false}},
                {id       : 'COL_MONTH_1' ,text     : '1월'   ,width    : 60,align    : 'right',renderer: renderNumber, dataIndex: 'VAL_MONTH_01' ,editor: {allowBlank: false}},
                {id       : 'COL_MONTH_2' ,text     : '2월'   ,width    : 60,align    : 'right',renderer: renderNumber, dataIndex: 'VAL_MONTH_02' ,editor: {allowBlank: false}},
                {id       : 'COL_MONTH_3' ,text     : '3월'   ,width    : 60,align    : 'right',renderer: renderNumber, dataIndex: 'VAL_MONTH_03' ,editor: {allowBlank: false}},
                {id       : 'COL_MONTH_4' ,text     : '4월'   ,width    : 60,align    : 'right',renderer: renderNumber, dataIndex: 'VAL_MONTH_04' ,editor: {allowBlank: false}},
                {id       : 'COL_MONTH_5' ,text     : '5월'   ,width    : 60,align    : 'right',renderer: renderNumber, dataIndex: 'VAL_MONTH_05' ,editor: {allowBlank: false}},
                {id       : 'COL_MONTH_6' ,text     : '6월'   ,width    : 60,align    : 'right',renderer: renderNumber, dataIndex: 'VAL_MONTH_06' ,editor: {allowBlank: false}},
                {id       : 'COL_MONTH_7' ,text     : '7월'   ,width    : 60,align    : 'right',renderer: renderNumber, dataIndex: 'VAL_MONTH_07' ,editor: {allowBlank: false}},
                {id       : 'COL_MONTH_8' ,text     : '8월'   ,width    : 60,align    : 'right',renderer: renderNumber, dataIndex: 'VAL_MONTH_08' ,editor: {allowBlank: false}},
                {id       : 'COL_MONTH_9' ,text     : '9월'   ,width    : 60,align    : 'right',renderer: renderNumber, dataIndex: 'VAL_MONTH_09' ,editor: {allowBlank: false}},
                {id       : 'COL_MONTH_10',text     : '10월'  ,width    : 60,align    : 'right',renderer: renderNumber, dataIndex: 'VAL_MONTH_10',editor: {allowBlank: false}},
                {id       : 'COL_MONTH_11',text     : '11월'  ,width    : 60,align    : 'right',renderer: renderNumber, dataIndex: 'VAL_MONTH_11',editor: {allowBlank: false}},
                {id       : 'COL_MONTH_12',text     : '12월'  ,width    : 60,align    : 'right',renderer: renderNumber, dataIndex: 'VAL_MONTH_12',editor: {allowBlank: false}}
            ]
        },{
            text: '주간',
            columns: [
                {id       : 'COL_WEEK_Y',text     : '기준년',width    : 80,align    : 'right',dataIndex: 'YEAR',        editor: {allowBlank: false}},
                {id       : 'COL_WEEK_M',text     : '기준월',width    : 80,align    : 'right',dataIndex: 'MONTH',       editor: {allowBlank: false}},
                {id       : 'COL_WEEK_1',text     : '1주차' ,width    : 60,align    : 'right',renderer: renderNumber, dataIndex: 'VAL_WEEK_01',editor: {allowBlank: false}}, 
                {id       : 'COL_WEEK_2',text     : '2주차' ,width    : 60,align    : 'right',renderer: renderNumber, dataIndex: 'VAL_WEEK_02',editor: {allowBlank: false}}, 
                {id       : 'COL_WEEK_3',text     : '3주차' ,width    : 60,align    : 'right',renderer: renderNumber, dataIndex: 'VAL_WEEK_03',editor: {allowBlank: false}}, 
                {id       : 'COL_WEEK_4',text     : '4주차' ,width    : 60,align    : 'right',renderer: renderNumber, dataIndex: 'VAL_WEEK_04',editor: {allowBlank: false}}, 
                {id       : 'COL_WEEK_5',text     : '5주차' ,width    : 60,align    : 'right',renderer: renderNumber, dataIndex: 'VAL_WEEK_05',editor: {allowBlank: false}}
            ]
        },
/*
,{
            text: '일간',
            columns: [
            {id       : 'COL_DAY_Y',    text     : '기준년',width    : 80,dataIndex: 'YEAR' ,align    : 'right',editor: {allowBlank: false}},
            {id       : 'COL_DAY_M',    text     : '기준월',width    : 80,dataIndex: 'MONTH',align    : 'right',editor: {allowBlank: false}},
            {id       : 'COL_DAY_1',    text     : '1',     width    : 60,align    : 'right',dataIndex: 'VAL_DAY_01' ,editor: {allowBlank: false}}, 
            {id       : 'COL_DAY_2',    text     : '2',     width    : 60,align    : 'right',dataIndex: 'VAL_DAY_02' ,editor: {allowBlank: false}}, 
            {id       : 'COL_DAY_3',    text     : '3',	    width    : 60,align    : 'right',dataIndex: 'VAL_DAY_03' ,editor: {allowBlank: false}}, 
            {id       : 'COL_DAY_4',    text     : '4',     width    : 60,align    : 'right',dataIndex: 'VAL_DAY_04' ,editor: {allowBlank: false}}, 
            {id       : 'COL_DAY_5',    text     : '5',     width    : 60,align    : 'right',dataIndex: 'VAL_DAY_05' ,editor: {allowBlank: false}},
            {id       : 'COL_DAY_6',    text     : '6',     width    : 60,align    : 'right',dataIndex: 'VAL_DAY_06' ,editor: {allowBlank: false}}, 
            {id       : 'COL_DAY_7',    text     : '7',     width    : 60,align    : 'right',dataIndex: 'VAL_DAY_07' ,editor: {allowBlank: false}}, 
            {id       : 'COL_DAY_8',    text     : '8',     width    : 60,align    : 'right',dataIndex: 'VAL_DAY_08' ,editor: {allowBlank: false}}, 
            {id       : 'COL_DAY_9',    text     : '9',     width    : 60,align    : 'right',dataIndex: 'VAL_DAY_09' ,editor: {allowBlank: false}}, 
            {id       : 'COL_DAY_10',   text     : '10',    width    : 60,align    : 'right',dataIndex: 'VAL_DAY_10',editor: {allowBlank: false}},
            {id       : 'COL_DAY_11',   text     : '11',    width    : 60,align    : 'right',dataIndex: 'VAL_DAY_11',editor: {allowBlank: false}}, 
            {id       : 'COL_DAY_12',   text     : '12',    width    : 60,align    : 'right',dataIndex: 'VAL_DAY_12',editor: {allowBlank: false}}, 
            {id       : 'COL_DAY_13',	text     : '13',    width    : 60,align    : 'right',dataIndex: 'VAL_DAY_13',editor: {allowBlank: false}}, 
            {id       : 'COL_DAY_14',   text     : '14',    width    : 60,align    : 'right',dataIndex: 'VAL_DAY_14',editor: {allowBlank: false}}, 
            {id       : 'COL_DAY_15',   text     : '15',    width    : 60,align    : 'right',dataIndex: 'VAL_DAY_15',editor: {allowBlank: false}},
            {id       : 'COL_DAY_16',   text     : '16',    width    : 60,align    : 'right',dataIndex: 'VAL_DAY_16',editor: {allowBlank: false}}, 
            {id       : 'COL_DAY_17',   text     : '17',    width    : 60,align    : 'right',dataIndex: 'VAL_DAY_17',editor: {allowBlank: false}}, 
            {id       : 'COL_DAY_18',	text     : '18',    width    : 60,align    : 'right',dataIndex: 'VAL_DAY_18',editor: {allowBlank: false}}, 
            {id       : 'COL_DAY_19',	text     : '19',	width    : 60,align    : 'right',dataIndex: 'VAL_DAY_19',editor: {allowBlank: false}}, 
            {id       : 'COL_DAY_20',   text     : '20',	width    : 60,align    : 'right',dataIndex: 'VAL_DAY_20',editor: {allowBlank: false}},
            {id       : 'COL_DAY_21',   text     : '21',	width    : 60,align    : 'right',dataIndex: 'VAL_DAY_21',editor: {allowBlank: false}}, 
            {id       : 'COL_DAY_22',   text     : '22',	width    : 60,align    : 'right',dataIndex: 'VAL_DAY_22',editor: {allowBlank: false}}, 
            {id       : 'COL_DAY_23',   text     : '23',	width    : 60,align    : 'right',dataIndex: 'VAL_DAY_23',editor: {allowBlank: false}}, 
            {id       : 'COL_DAY_24',   text     : '24',	width    : 60,align    : 'right',dataIndex: 'VAL_DAY_24',editor: {allowBlank: false}}, 
            {id       : 'COL_DAY_25',   text     : '25',	width    : 60,align    : 'right',dataIndex: 'VAL_DAY_25',editor: {allowBlank: false}},
            {id       : 'COL_DAY_26',   text     : '26',	width    : 60,align    : 'right',dataIndex: 'VAL_DAY_26',editor: {allowBlank: false}}, 
            {id       : 'COL_DAY_27',   text     : '27',    width    : 60,align    : 'right',dataIndex: 'VAL_DAY_27',editor: {allowBlank: false}}, 
            {id       : 'COL_DAY_28',   text     : '28',    width    : 60,align    : 'right',dataIndex: 'VAL_DAY_28',editor: {allowBlank: false}}, 
            {id       : 'COL_DAY_29',   text     : '29',    width    : 60,align    : 'right',dataIndex: 'VAL_DAY_29',editor: {allowBlank: false}}, 
            {id       : 'COL_DAY_30',   text     : '30',    width    : 60,align    : 'right',dataIndex: 'VAL_DAY_30',editor: {allowBlank: false}}, 
            {id       : 'COL_DAY_31',   text     : '31',    width    : 60,align    : 'right',dataIndex: 'VAL_DAY_31',editor: { allowBlank: false  } }
            ]
        }
*/
        
        {
            text     : '소유권',
            width    : 180,
            dataIndex: 'ATTR3',
            renderer : renderPERSON,
            editor: COMBO_PERSON
            
            //editor: {
            //    allowBlank: false
            //}
        },
        {
            text     : '최종수정일',
            width    : 120,
            dataIndex: 'UPDATE_DATE',
            renderer : renderDATE,
            editor: null
        },
        {
            text     : '최종수정자',
            width    : 100,
            dataIndex: 'UPDATOR_ID',
            editor: null
        }

        ] },
        tbar  : grid_toolbar = new Ext.Toolbar({
            cls:'top-toolbar',
            items:[ '->' ,{
/*                    xtype : 'combo',
                    id: 'ID_FILTERCOMBO1',
                    width: 80,
                    queryMode:'local',
                    displayField: 'view',
                    valueField: 'value',
                    store: STORE_DIV,
                },{
                    xtype : 'combo',
                    id: 'ID_FILTERCOMBO2',
                    width: 80,
                    queryMode:'local',
                    displayField: 'view',
                    valueField: 'value',
                    store: STORE_CYCLE,
                },{
                    xtype : 'textfield',
                    id: 'ID_FILTERTEXT',
                    width: 100,
                },{
                text:'검색',
                handler: function(){ 
                    if( select_tree_id != null ){
                        //----------
                    } }
                },{
                text:'추가',
//iconCls: 'print' ,
                tooltip: 'Expand All',
                handler: function(){ 
                    //changeView( grid, "YEAR" );
                    var r = getDefaultOBJECT();
                    store.add( r ); // insert( 0, r ) 로 하니까.. 한번만 되고 이후로 ERROR..
                } },{
                text:'삭제',
                tooltip: 'Expand All',
                handler: function(){ 
                    if( select_tree_id != null ){
                        Ext.MessageBox.prompt('확인', '변경될 분류 명칭을 입력해주십시오', action_cls_modify );
                    } }
                },{ */

                text:'추가',
                tooltip: 'Expand All',
                handler: function(){ 
                    //changeView( grid, "YEAR" );
                    var r = getDefaultOBJECT();
                    store.add( r ); // insert( 0, r ) 로 하니까.. 한번만 되고 이후로 ERROR..
                } },{
                text:'삭제',
                tooltip: 'Expand All',
                handler: function(){ 
                    removeGRID( grid, store );
                } },{
                text:'저장',
                tooltip: 'Expand All',
                handler: function(){ 
                    saveGRID( grid, store );
                    }
                }
            ]
        }),
        autoHeight:true,
        region: 'center',
        viewConfig: {
            stripeRows: true,
            forceFit: true,
            listeners: {
                refresh: function(dataView) {
                    Ext.each(dataView.panel.columns, function(column) {
                        if( column.dataIndex.indexOf( 'VAL_' ) >= 0 )
                        {
                            column.autoSize();
                            column.width += 5;
                            if( column.width < 60 ) column.width = 60;
                        }   
                    });
                }
            }
        }
    });


grid.on( 'rowdblclick', function( target, record, tr, rowIndex, e, opts ){
//    var projectcode = record.data.PrjCode;
//    var object_id = record.data.Object_Id;
//    this.location = URL_DETAIL + "&PRJCODE=" + projectcode + "&ObjectId=" + object_id;;
}, self );



grid.on('edit', function(editor, e, eOpts ) {
    var field = e.field;
    var value = e.value.replace(/ /gi,"" ); // ','는 제외해주자..

    if( e.value == ' ' ) value = ' ';
    if( field != null && field.indexOf( 'VAL_' ) >= 0 ){

        if( e.value.indexOf( ',' ) >= 0 ){
            e.record.data[field] = value.replace(/,/gi,"" );
        }else
        {
            e.record.data[field] = value;
        }

        if( e.record.data["ATTR1"] == true )
        {
            var old_value = e.record.data["VAL_YEAR_01"];
                
            var new_value =  (
                _parseInt ( e.record.data["VAL_MONTH_01" ] ) +
                _parseInt ( e.record.data["VAL_MONTH_02" ] ) +
                _parseInt ( e.record.data["VAL_MONTH_03" ] ) +
                _parseInt ( e.record.data["VAL_MONTH_04" ] ) +
                _parseInt ( e.record.data["VAL_MONTH_05" ] ) +
                _parseInt ( e.record.data["VAL_MONTH_06" ] ) +
                _parseInt ( e.record.data["VAL_MONTH_07" ] ) +
                _parseInt ( e.record.data["VAL_MONTH_08" ] ) +
                _parseInt ( e.record.data["VAL_MONTH_09" ] ) +
                _parseInt ( e.record.data["VAL_MONTH_10" ] ) +
                _parseInt ( e.record.data["VAL_MONTH_11" ] ) +
                _parseInt ( e.record.data["VAL_MONTH_12" ] ) ) + ""; 

            if( old_value != new_value ){
                //var tmpRec = e.store.getAt( e.rowIdx );
                //tmpRec.set( e.column.getIndex( "COL_YEAR_1")  + 4 );
                e.record.data["VAL_YEAR_01"] = new_value;
            }

            if( field == "VAL_YEAR_01" )
            {
                alert( '누계가 적용되어 월별 합산값이 자동으로 계산됩니다.' );
            }
        }

        grid.getView().refresh();
    }
});

grid.on('validateedit', function(editor, e, eOpts ) {
    var field = e.field;
    var value = e.value;
    if( field == 'YEAR' )
    {
        var v1 = parseInt( e.value );
        if( v1 != e.value ){
            alert( '숫자를 입력해주십시오.');
            e.cancel = true; return;
        }
        if( v1 < 2016 || v1 > 2100 ){
            alert( '입력된 값을 확인해주십시오.');
            e.cancel = true; return;
        }
    }
    if( field == 'MONTH' )
    {
        var v1 = parseInt( e.value );
        if( v1 != e.value ){
            alert( '숫자를 입력해주십시오.');
            e.cancel = true; return;
        }
        if( v1 < 1 || v1 > 12 ){
            alert( '입력된 값을 확인해주십시오.');
            e.cancel = true; return;
        }
    }
    if( field.indexOf( 'VAL' ) >= 0 )
    {
        var value1 = e.value.replace(/ /gi,"" ); // ','는 제외해주자..
        value1 = value1.replace(/,/gi,"" ); // ','는 제외해주자..
        //var number = /[-+]?[0-9]*\.?[0-9]+/;
        var number = /^[+-]?\d*(\.?\d*)$/
        if( !number.test( value1 ) ){
            alert( '입력된 값을 확인해주십시오.');
            e.cancel = true; return;
        }
    }
});

var targetcall = 0;
var callback = 0;
var callmsg = '';

function removeGRID( grid, store ){
    var record = grid.getSelectionModel().getSelected();
    if( record == null ){
        alert('대상을 선택해 주십시오.' );
        return;
    }
    if( record.length != 1 ) {
        alert('대상을 1개만 선택해 주십시오.' );
        return;
    }
    
    var msg = record.items[0].data.TITLE;
    var callmsg = '';
    if( confirm( '다음 항목을 삭제 하시겠습니까?\r\n' + msg ) )
    {
        var url = '/Process.aspx?action=ObjDel&OBJECT_ID=' + record.items[0].data.OBJECT_ID;
        Ext.Ajax.request({
            url:url,
            //params: { 'OBJECT_ID' : record.data },
            jsonData : record.data,
            method:'POST',
            success:function( result, request ){
                var jsonData = Ext.JSON.decode(result.responseText);
                var res = jsonData.RESULT;
                if( res == 'true' )
                {
                    callmsg += "\r\n성공:[" + msg + "]";
                }else{
                    callmsg += "\r\n실패:[" + msg + "]";
                }
                
                alert( "작업을 완료 하였습니다." + callmsg );
                reloadList( select_tree_id );
            },
            failure:function(result,request){
                callmsg += "\r\n실패:[" + msg + "]";
                alert( "작업을 완료 하였습니다." + callmsg );
                reloadList( select_tree_id );
            }
        });
    }
}
  


function saveGRID( grid, store ){
    var items = grid.store.data.items;
    var msg = '';
    var cnt = 0;
    for( var i = 0; i < items.length; i++ ){
        var record = items[i];
        if( record.dirty ){
            msg += "\r\n[" + record.data.TITLE + "]";
            cnt++;
        }
    }
    if( confirm( '다음의 항목을 업데이트 하시겠습니까?' + msg ) )
    {
        var success = '';
        var failure = '';
        var current = '';
        targetcall = cnt;
        callback = 0;
        callmsg = '';

        for( var i = 0; i < items.length; i++ ){
            var record = items[i];
            current= record.data.TITLE;
            if( record.dirty ){
                url = '/Process.aspx?action=ObjMod';
                if( record.data.OBJECT_ID == 0 || record.data.OBJECT_ID == '' )
                {
                    url = '/Process.aspx?action=ObjIns&CATE_PCODE=' + tree.getRootNode().findChild('id',select_tree_id,true ).data.OBJECT_ID;
                }
                Ext.Ajax.request({
                    url:url,
                    //params: { 'OBJECT_ID' : record.data },
                    jsonData : record.data,
                    method:'POST',
                    success:function( result, request ){
                        callback++;
                        var jsonData = Ext.JSON.decode(result.responseText);
                        var res = jsonData.RESULT;

                        if( res == 'true' )
                        {
                            callmsg += "\r\n성공:[" + request.jsonData.TITLE  + "]";
                        }else{
                            var msg = jsonData.MESSAGE;
                            if( msg != null )
                                callmsg += "\r\n실패:[" + request.jsonData.TITLE + "] 사유:" + msg;
                            else 
                                callmsg += "\r\n실패:[" + request.jsonData.TITLE + "]";
                        }
                        if( callback == targetcall )
                        {
                            alert( "작업을 완료 하였습니다." + callmsg );
                            reloadList( select_tree_id );
                        }
                    },
                    failure:function(result,request){
                        callback++;
                        callmsg += "\r\n실패:[" + request.jsonData.TITLE + "]";
                        if( callback == targetcall )
                        {
                            alert( "작업을 완료 하였습니다." + callmsg );
                            reloadList( select_tree_id );
                        }
                    }
                });
            }
        }
    } 
}

function changeView( grid, mode ){
    var m = grid.columnManager;
    return;
    if( mode == "YEAR" )
    {
        m.getHeaderById( "COL_YEAR_Y" ).setHidden( false );
        m.getHeaderById( "COL_YEAR_1" ).setHidden( false );
    }else
    {
        m.getHeaderById( "COL_YEAR_Y" ).setHidden( true );
        m.getHeaderById( "COL_YEAR_1" ).setHidden( true );
    }
    if( mode == "HALF" )
    {
        m.getHeaderById( "COL_HALF_Y" ).setHidden( false );
        m.getHeaderById( "COL_HALF_1" ).setHidden( false );
        m.getHeaderById( "COL_HALF_2" ).setHidden( false );
    }else
    {
        m.getHeaderById( "COL_HALF_Y" ).setHidden( true );
        m.getHeaderById( "COL_HALF_1" ).setHidden( true );
        m.getHeaderById( "COL_HALF_2" ).setHidden( true );
    }

    if( mode == "QTR" )
    {
        m.getHeaderById( "COL_QTR_Y" ).setHidden( false );
        m.getHeaderById( "COL_QTR_1" ).setHidden( false );
        m.getHeaderById( "COL_QTR_2" ).setHidden( false );
        m.getHeaderById( "COL_QTR_3" ).setHidden( false );
        m.getHeaderById( "COL_QTR_4" ).setHidden( false );
    }else
    {
        m.getHeaderById( "COL_QTR_Y" ).setHidden( true );
        m.getHeaderById( "COL_QTR_1" ).setHidden( true );
        m.getHeaderById( "COL_QTR_2" ).setHidden( true );
        m.getHeaderById( "COL_QTR_3" ).setHidden( true );
        m.getHeaderById( "COL_QTR_4" ).setHidden( true );
    }

    if( mode == "MONTH" )
    {
        m.getHeaderById( "COL_MONTH_Y" ).setHidden( false );
        m.getHeaderById( "COL_MONTH_1" ).setHidden( false );
        m.getHeaderById( "COL_MONTH_2" ).setHidden( false );
        m.getHeaderById( "COL_MONTH_3" ).setHidden( false );
        m.getHeaderById( "COL_MONTH_4" ).setHidden( false );
        m.getHeaderById( "COL_MONTH_5" ).setHidden( false );
        m.getHeaderById( "COL_MONTH_6" ).setHidden( false );
        m.getHeaderById( "COL_MONTH_7" ).setHidden( false );
        m.getHeaderById( "COL_MONTH_8" ).setHidden( false );
        m.getHeaderById( "COL_MONTH_9" ).setHidden( false );
        m.getHeaderById( "COL_MONTH_10" ).setHidden( false );
        m.getHeaderById( "COL_MONTH_11" ).setHidden( false );
        m.getHeaderById( "COL_MONTH_12" ).setHidden( false );
    }else
    {
        m.getHeaderById( "COL_MONTH_Y" ).setHidden( true );
        m.getHeaderById( "COL_MONTH_1" ).setHidden( true );
        m.getHeaderById( "COL_MONTH_2" ).setHidden( true );
        m.getHeaderById( "COL_MONTH_3" ).setHidden( true );
        m.getHeaderById( "COL_MONTH_4" ).setHidden( true );
        m.getHeaderById( "COL_MONTH_5" ).setHidden( true );
        m.getHeaderById( "COL_MONTH_6" ).setHidden( true );
        m.getHeaderById( "COL_MONTH_7" ).setHidden( true );
        m.getHeaderById( "COL_MONTH_8" ).setHidden( true );
        m.getHeaderById( "COL_MONTH_9" ).setHidden( true );
        m.getHeaderById( "COL_MONTH_10" ).setHidden( true );
        m.getHeaderById( "COL_MONTH_11" ).setHidden( true );
        m.getHeaderById( "COL_MONTH_12" ).setHidden( true );
    }


    if( mode == "WEEK" )
    {
        m.getHeaderById( "COL_WEEK_Y" ).setHidden( false );
        m.getHeaderById( "COL_WEEK_M" ).setHidden( false );
        m.getHeaderById( "COL_WEEK_1" ).setHidden( false );
        m.getHeaderById( "COL_WEEK_2" ).setHidden( false );
        m.getHeaderById( "COL_WEEK_3" ).setHidden( false );
        m.getHeaderById( "COL_WEEK_4" ).setHidden( false );
        m.getHeaderById( "COL_WEEK_5" ).setHidden( false );
    }else
    {
        m.getHeaderById( "COL_WEEK_Y" ).setHidden( true );
        m.getHeaderById( "COL_WEEK_M" ).setHidden( true );
        m.getHeaderById( "COL_WEEK_1" ).setHidden( true );
        m.getHeaderById( "COL_WEEK_2" ).setHidden( true );
        m.getHeaderById( "COL_WEEK_3" ).setHidden( true );
        m.getHeaderById( "COL_WEEK_4" ).setHidden( true );
        m.getHeaderById( "COL_WEEK_5" ).setHidden( true );
    }


    if( mode == "DAY" )
    {
        m.getHeaderById( "COL_DAY_Y" ).setHidden( false );
        m.getHeaderById( "COL_DAY_M" ).setHidden( false );
        m.getHeaderById( "COL_DAY_1" ).setHidden( false );
        m.getHeaderById( "COL_DAY_2" ).setHidden( false );
        m.getHeaderById( "COL_DAY_3" ).setHidden( false );
        m.getHeaderById( "COL_DAY_4" ).setHidden( false );
        m.getHeaderById( "COL_DAY_5" ).setHidden( false );
        m.getHeaderById( "COL_DAY_6" ).setHidden( false );
        m.getHeaderById( "COL_DAY_7" ).setHidden( false );
        m.getHeaderById( "COL_DAY_8" ).setHidden( false );
        m.getHeaderById( "COL_DAY_9" ).setHidden( false );
        m.getHeaderById( "COL_DAY_10" ).setHidden( false );
        m.getHeaderById( "COL_DAY_11" ).setHidden( false );
        m.getHeaderById( "COL_DAY_12" ).setHidden( false );
        m.getHeaderById( "COL_DAY_13" ).setHidden( false );
        m.getHeaderById( "COL_DAY_14" ).setHidden( false );
        m.getHeaderById( "COL_DAY_15" ).setHidden( false );
        m.getHeaderById( "COL_DAY_16" ).setHidden( false );
        m.getHeaderById( "COL_DAY_17" ).setHidden( false );
        m.getHeaderById( "COL_DAY_18" ).setHidden( false );
        m.getHeaderById( "COL_DAY_19" ).setHidden( false );
        m.getHeaderById( "COL_DAY_20" ).setHidden( false );
        m.getHeaderById( "COL_DAY_21" ).setHidden( false );
        m.getHeaderById( "COL_DAY_22" ).setHidden( false );
        m.getHeaderById( "COL_DAY_23" ).setHidden( false );
        m.getHeaderById( "COL_DAY_24" ).setHidden( false );
        m.getHeaderById( "COL_DAY_25" ).setHidden( false );
        m.getHeaderById( "COL_DAY_26" ).setHidden( false );
        m.getHeaderById( "COL_DAY_27" ).setHidden( false );
        m.getHeaderById( "COL_DAY_28" ).setHidden( false );
        m.getHeaderById( "COL_DAY_29" ).setHidden( false );
        m.getHeaderById( "COL_DAY_30" ).setHidden( false );
        m.getHeaderById( "COL_DAY_31" ).setHidden( false );
    }else
    {
        m.getHeaderById( "COL_DAY_Y" ).setHidden( true );
        m.getHeaderById( "COL_DAY_M" ).setHidden( true );
        m.getHeaderById( "COL_DAY_1" ).setHidden( true );
        m.getHeaderById( "COL_DAY_2" ).setHidden( true );
        m.getHeaderById( "COL_DAY_3" ).setHidden( true );
        m.getHeaderById( "COL_DAY_4" ).setHidden( true );
        m.getHeaderById( "COL_DAY_5" ).setHidden( true );
        m.getHeaderById( "COL_DAY_6" ).setHidden( true );
        m.getHeaderById( "COL_DAY_7" ).setHidden( true );
        m.getHeaderById( "COL_DAY_8" ).setHidden( true );
        m.getHeaderById( "COL_DAY_9" ).setHidden( true );
        m.getHeaderById( "COL_DAY_10" ).setHidden( true );
        m.getHeaderById( "COL_DAY_11" ).setHidden( true );
        m.getHeaderById( "COL_DAY_12" ).setHidden( true );
        m.getHeaderById( "COL_DAY_13" ).setHidden( true );
        m.getHeaderById( "COL_DAY_14" ).setHidden( true );
        m.getHeaderById( "COL_DAY_15" ).setHidden( true );
        m.getHeaderById( "COL_DAY_16" ).setHidden( true );
        m.getHeaderById( "COL_DAY_17" ).setHidden( true );
        m.getHeaderById( "COL_DAY_18" ).setHidden( true );
        m.getHeaderById( "COL_DAY_19" ).setHidden( true );
        m.getHeaderById( "COL_DAY_20" ).setHidden( true );
        m.getHeaderById( "COL_DAY_21" ).setHidden( true );
        m.getHeaderById( "COL_DAY_22" ).setHidden( true );
        m.getHeaderById( "COL_DAY_23" ).setHidden( true );
        m.getHeaderById( "COL_DAY_24" ).setHidden( true );
        m.getHeaderById( "COL_DAY_25" ).setHidden( true );
        m.getHeaderById( "COL_DAY_26" ).setHidden( true );
        m.getHeaderById( "COL_DAY_27" ).setHidden( true );
        m.getHeaderById( "COL_DAY_28" ).setHidden( true );
        m.getHeaderById( "COL_DAY_29" ).setHidden( true );
        m.getHeaderById( "COL_DAY_30" ).setHidden( true );
        m.getHeaderById( "COL_DAY_31" ).setHidden( true );
    }
    grid.getView().refresh();
}

Ext.getBody().setStyle('overflow', 'auto');
var anchor = 
Ext.create('Ext.container.Viewport', {
    autoScroll: true,
    layout: 'border',
    viewConfig: { autoScroll: true } ,
    items: [{
        region: 'north',
        html: '<h1 class="x-panel-header"> &nbsp; &nbsp; &nbsp; 전자 현황판 관리</h1>',
        border: false,
        margin: '0 0 5 0'
    }, 
{
        region: 'west',
        collapsible: true,
        title: '분류',
        width: 250,
	height: 15000,
        items: [
            tree
        ]
    }

 , grid ]
});



    tree.expandPath( lastPath, afterExpand() );
    tree.selectPath( lastPath );
    select_tree_id = lastPath.substring( lastPath.lastIndexOf( "/" ) + 1);


    var map = new Ext.KeyMap(grid.getEl(), 
    [{
        key: "c",
        ctrl:true,
        fn: function(keyCode, e) {
            var recs = grid.getSelectionModel().getSelection();
            if (recs && recs.length != 0) {
                var clipText = getCsvDataFromRecs(recs);
                var ta = document.createElement('textarea');
                ta.id = 'cliparea';
                ta.style.position = 'absolute';
                ta.style.left = '-1000px';
                ta.style.top = '-1000px';
                ta.value = clipText;
                document.body.appendChild(ta);
                document.designMode = 'off';
                ta.focus();
                ta.select();
                setTimeout(function(){
                   document.body.removeChild(ta);
                }, 100);
            }
        }
    },{
        key: "v",
        ctrl:true,
        fn: function() {
            var ta = document.createElement('textarea');
            ta.id = 'cliparea';
            ta.style.position = 'absolute';
            ta.style.left = '-1000px';
            ta.style.top = '-1000px';
            ta.value = '';
            document.body.appendChild(ta);
            document.designMode = 'off';
            setTimeout(function(){
                getRecsFromCsv(ta);
                //Ext.getCmp('grid-pnl').getRecsFromCsv(grid, ta);
            }, 100);
            ta.focus();
            ta.select();
        }
    }]);

    reloadList( select_tree_id )
    setTreeHeight();
});

function isNull( value ){
    if( value == null ) return '';
    else return value;
}
function getRecsFromCsv( ta ){

    document.body.removeChild(ta);
    var del = '';
    if (ta.value.indexOf("\r\n")) {
        del = "\r\n";
    } else if (ta.value.indexOf("\n")) {
        del = "\n"
    }
    var idxRow = grid.getSelectionModel().getCurrentPosition().rowIdx;
    var idxCol = selectIdx;

    //alert( idxRow + "|----|" + idxCol + "|-------|" );
    if( idxRow < 0 || idxCol <= 0) 
    {
        Ext.Msg.alert('값을 입력하는 부분에서만 붙여넣기를 할 수 있습니다.');
		return;
	}
    
    var columns = commonCols;

    var rows = ta.value.split("\n");
    for (var i=0; i<rows.length; i++) {

        var cfg = {};
        var tmpRec = store.getAt( idxRow + i );

        
        var existing = false;

        if ( tmpRec )
        {
            cfg = tmpRec.data;
            existing = true;
        }

        var cols = rows[i].split("\t");
        var l = cols.length;
        if ( ( cols.length + idxCol ) > columns.length )
				l = columns.length;
        for (var j=0; j<l; j++)
		{
			if (cols[j] == "")
				return;
			tmpRec.set( columns[j+idxCol+4] );
			cfg[columns[j+idxCol+4]] = cols[j].replace( / /gi, "" );
		}
        grid.getView().refresh();
    }
}

function getCsvDataFromRecs( records) {
    var clipText = '';
    var currRow = store.find('id',records[0].data.id);

    clipText = clipText.concat(  "관리명칭", "\t");
    clipText = clipText.concat(  "유형" , "\t");
    clipText = clipText.concat(  "단위" , "\t");
    clipText = clipText.concat(  "지표ID" , "\t");
    clipText = clipText.concat(  "사업부" , "\t");
    clipText = clipText.concat(  "주관부서" , "\t");
    clipText = clipText.concat(  "누계" , "\t");
    //clipText = clipText.concat(  "제공장소" , "\t");
    clipText = clipText.concat(  "목표_입력주기" , "\t");
    clipText = clipText.concat(  "실적_입력주기" , "\t");
    clipText = clipText.concat(  "기준년" , "\t");
    clipText = clipText.concat(  "기준월" , "\t");
    clipText = clipText.concat(  "기준년" , "\t");
    clipText = clipText.concat(  "목표/실적" , "\t");
    clipText = clipText.concat(  "1월" , "\t");
    clipText = clipText.concat(  "2월" , "\t");
    clipText = clipText.concat(  "3월" , "\t");
    clipText = clipText.concat(  "4월" , "\t");
    clipText = clipText.concat(  "5월" , "\t");
    clipText = clipText.concat(  "6월" , "\t");
    clipText = clipText.concat(  "7월" , "\t");
    clipText = clipText.concat(  "8월" , "\t");
    clipText = clipText.concat(  "9월" , "\t");
    clipText = clipText.concat(  "10월" , "\t");
    clipText = clipText.concat(  "11월" , "\t");
    clipText = clipText.concat(  "12월" , "\t");
    clipText = clipText.concat(  "기준년" , "\t");
    clipText = clipText.concat(  "기준월" , "\t");
    clipText = clipText.concat(  "1주차" , "\t");
    clipText = clipText.concat(  "2주차" , "\t");
    clipText = clipText.concat(  "3주차" , "\t");
    clipText = clipText.concat(  "4주차" , "\t");
    clipText = clipText.concat(  "5주차" , "\t");
    clipText = clipText.concat(  "추가속성" , "\t");
    clipText = clipText.concat( "\n");

    for (var i=0; i<records.length; i++) {
        var index = store.find('id',records[i].data.id);
        var r = index;
        var rec = records[i];
        var cv = grid.initialConfig.columns;

        clipText = clipText.concat(  isNull( rec.data[ "TITLE" ], '' ), "\t");
        clipText = clipText.concat(  renderINPUT( rec.data[ "INPUT_TYPE" ], '' ), "\t");
        clipText = clipText.concat(  renderUNIT( rec.data[ "UNIT" ], '' ), "\t");
        clipText = clipText.concat(  isNull( rec.data[ "CODE" ], '' ), "\t");
        clipText = clipText.concat(  renderDIV( rec.data[ "DIVISION" ], '' ), "\t");
        clipText = clipText.concat(  renderDEPT( rec.data[ "OWNER" ], '' ), "\t");
        {
            var v1 = rec.data[ "ATTR1" ];
            if( v1 == true ) v1 = "누계"; else v1 = '';
            clipText = clipText.concat(  v1 , "\t");

            //var v2 = rec.data[ "ATTR2" ];
            //if( v2 == true ) v2 = "기타"; else v2 = '';
            //clipText = clipText.concat(  v2 , "\t");
        }
        clipText = clipText.concat(  renderCYCLE( rec.data[ "INPUT_CYCLE" ], '' ), "\t");
        clipText = clipText.concat(  renderCYCLE( rec.data[ "INPUT_CYCLE2" ], '' ), "\t");
        clipText = clipText.concat(  isNull( rec.data[ "YEAR" ], '' ), "\t");
        clipText = clipText.concat(  isNull( rec.data[ "MONTH" ], '' ), "\t");
        clipText = clipText.concat(  isNull( rec.data[ "YEAR" ], '' ), "\t");
        clipText = clipText.concat(  isNull( rec.data[ "VAL_YEAR_01" ], '' ), "\t");
        clipText = clipText.concat(  isNull( rec.data[ "VAL_MONTH_01" ], '' ), "\t");
        clipText = clipText.concat(  isNull( rec.data[ "VAL_MONTH_02" ], '' ), "\t");
        clipText = clipText.concat(  isNull( rec.data[ "VAL_MONTH_03" ], '' ), "\t");
        clipText = clipText.concat(  isNull( rec.data[ "VAL_MONTH_04" ], '' ), "\t");
        clipText = clipText.concat(  isNull( rec.data[ "VAL_MONTH_05" ], '' ), "\t");
        clipText = clipText.concat(  isNull( rec.data[ "VAL_MONTH_06" ], '' ), "\t");
        clipText = clipText.concat(  isNull( rec.data[ "VAL_MONTH_07" ], '' ), "\t");
        clipText = clipText.concat(  isNull( rec.data[ "VAL_MONTH_08" ], '' ), "\t");
        clipText = clipText.concat(  isNull( rec.data[ "VAL_MONTH_09" ], '' ), "\t");
        clipText = clipText.concat(  isNull( rec.data[ "VAL_MONTH_10" ], '' ), "\t");
        clipText = clipText.concat(  isNull( rec.data[ "VAL_MONTH_11" ], '' ), "\t");
        clipText = clipText.concat(  isNull( rec.data[ "VAL_MONTH_12" ], '' ), "\t");
        clipText = clipText.concat(  isNull( rec.data[ "YEAR" ], '' ), "\t");
        clipText = clipText.concat(  isNull( rec.data[ "MONTH" ], '' ), "\t");
        clipText = clipText.concat(  isNull( rec.data[ "VAL_WEEK_01" ], '' ), "\t");
        clipText = clipText.concat(  isNull( rec.data[ "VAL_WEEK_02" ], '' ), "\t");
        clipText = clipText.concat(  isNull( rec.data[ "VAL_WEEK_03" ], '' ), "\t");
        clipText = clipText.concat(  isNull( rec.data[ "VAL_WEEK_04" ], '' ), "\t");
        clipText = clipText.concat(  isNull( rec.data[ "VAL_WEEK_05" ], '' ), "\t");
        clipText = clipText.concat(  isNull( rec.data[ "ATTR3" ], '' ), "\t");
        clipText = clipText.concat( "\n");
    }
    return clipText;
}


// 트리 확장이후.. 다음과 같이 데이터 로드 처리..
function afterExpand()
{
    var record = tree.getRootNode().findChild('id',select_tree_id,true);
    if( record == null ) return;
    select_tree_record = record.data;
    reloadList( record.clsCode );
}

function reloadList( clsCode )
{
    store.load( { params:{ 'clscode': clsCode  }, callback: function(records, operation, success){ 
        if( success == false  ){  
            alert( '데이터를 읽어오지 못하였습니다. \r\n재접속이 필요합니다.' ); 
            document.location.href='/loginFromGW.aspx';
        } 
    }  } );

    //grid.headerCt.items.items[0].setWidth(100);
    //this.getView().refresh();
}

function store_callback(){
    grid.getView().refresh();
}
function setTreeHeight(){
	tree.setHeight( document.body.clientHeight - 100 );
}

</script>


<style type="text/css">
 
.rept{
    margin-bottom:10px; 
}
.x-form-layout-wrap
{
        border-spacing: 0px;
}

.x-grid-cell-inner
{
        padding-bottom : 7px;
        padding-top : 8px;
}

DIV.TITLE{

padding-top : 25px;
}
</style>
    <body style="width:100%">
    </body>
</html>