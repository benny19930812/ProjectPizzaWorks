<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="spring" uri="http://www.springframework.org/tags"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>請購單</title>
<style>
textarea {
	resize: none;
}

</style>

</head>
<body>

	<section class="py-5">
		<div class="container-fluid">
			<div class="row">
				<div class="col-md-8 mx-auto">
					<div class="card">
						<div class="card-header bg-light">請購單</div>
						<div class="card-body">
							<form class="needs-validation" novalidate>
								<div class="form-group row ">
									<label for="requestTime" class="col-sm-2 col-form-label">日期</label>
									<div class='col-sm-4' id='requestTime'>
										<input type='text' class="form-control" disabled />
									</div>
								</div>
								<div class="form-group row ">
									<label for="proposalerName" class="col-sm-2 col-form-label">承辦人</label>
									<div class='col-sm-4' id='proposalerId'>
										<input type='text' class="form-control"
											value="${Mem_LoginOK.lastName}${Mem_LoginOK.firstName}" disabled />
										<input type="hidden" name="proposalerId" value="${Mem_LoginOK.memberId }"/>
									</div>
								</div>
								<div class="form-group row">
									<label for="totalPrice" class="col-sm-2 col-form-label">請購總額</label>
									<div class='col-sm-4' id='unitPrice'>
										<input type='text' name="totalPrice" id="totalPrice" class="form-control"
											value="" disabled required/>
									</div>
									<label for="totalSale" class="col-form-label control-label col-sm-3" ><i>新臺幣元</i></label>
								</div>
								<div class="form-group row">
									<label for="purchaseReason" class="col-sm-2 col-form-label">請購理由</label>
									<div class='col-sm-8' id='purchaseReason'>
										<textarea cols="100" rows="3" name = "purchaseReason" maxlength="500"
											class="form-control" placeholder="請簡述本次請購理由..." required></textarea>
										<div class="invalid-feedback">請輸入請購理由</div>
									</div>
								</div>
								<hr>
								
								<div class="row mt-2">
									<div class="mr-2">
										<button type="button" name="add" id="add" class="btn btn-info">新增品項</button>
									</div>
										<button type="button" id="to_submit" class="btn btn-success">送出請購單</button>
								</div>
								
								<br>
								<!-- <table id="prRequest" class="table table-striped text-center"> -->
								<table id="prRequest" class="display text-center">
									<thead>
										<tr>
											<th></th>
											<th>品項編號</th>
											<th>品項名稱</th>
											<th>請求數量</th>
											<th>每箱單價</th>
											<th>每箱數量</th>
											<th>每箱單位</th>
											<th></th>
										</tr>
									</thead>
								</table>
							</form>
						</div>
					</div>
				</div>
				<div class="col-md-4 d-none materials">
					<div class="card card-default">
						<div class="card-header bg-light">
							<div class="card-title">
								<i class="fas fa-box-open"></i> 庫存品項
							</div>
							<!-- card-title end -->
						</div>
						<!--  card-header end -->
						<div class="card-body">
							<table id="table_materials" class="table table-striped text-center">
								<thead>
									<tr>
										<th>&nbsp;</th>
										<th>品項編號</th>
										<th>品項名稱</th>
										<th>每箱單價</th>
										<th>每箱數量</th>
										<th>每箱單位</th>
									</tr>
								</thead>
							</table>
						</div>
					</div>
				</div>
			</div>
		</div>
	</section>
	<script>
		var materialsUnits = ${materialsUnits};
		var suppliersProvisions = ${suppliersProvisions};
		var itemBePending=[] ; 
		var itemsBeAdded=[]; 
		
		var materials = [
		<c:forEach var="material" items="${materials}" varStatus='status'>
			["","${material.materialsId}","${material.materialsName}",suppliersProvisions[parseInt('${material.materialsId}')-1].unitPrice,materialsUnits[parseInt('${material.materialsId}')-1].quantityPerUnit,materialsUnits[parseInt('${material.materialsId}')-1].unit]
			<c:if test="${!status.last}">,</c:if>
		</c:forEach>
		];
		var sRequestDetails = []; 

		$(document).ready(function() {
			var date = new Date();
			$("#requestTime input").val(date.yyyymmdd());
			materials_table();
			toggle_Item(); 
			fetch_data(); 
		})	
			
		
		// 對於明細表的操作
		var fetch_data = function() {
			var fetch_data = $('#prRequest').DataTable({
				"language": {
			      "emptyTable": "尚未有請購項目",
				},
				lengthChange: false,
				columnDefs: {
	                targets: [0],
	                "orderable": false,
	                data: null,
	            },
				"searching" : false,
				"info" : false,
			});
			delete_Item(fetch_data);
		}
		
		// 開關品項表
		function toggle_Item (){
			 $("#add").click(function(){ 
				if($(this).html()=="新增品項"){
					$(this).html("取消新增")
					$(".materials").removeClass("d-none");
					new_item_html();
					insert_Item();
				}else{
					$(this).html("新增品項");
					// 關閉品項欄
					$(".materials").addClass("d-none");
					$(".new_item").remove();
					// 將所有減號轉回加號
					$("#btnAddToRemove").children().removeClass("fa-minus").addClass("fa-plus");
					$("#btnAddToRemove").removeClass("btn-danger").addClass("btn-info");
					$("#btnAddToRemove").attr("id","btnRemoveToAdd");
				}
			})
		}
		
		
		// 將填入資料塞入附表表格
		function insert_Item (){
				$("#prRequest").on("click","#insert",function(e){
				e.preventDefault();

				if(validationInsert()){
					/* 塞到dateTables */
					var data = [];
					$(".new_item td:not(:first)").each(function(){
						value = $(this).html();
						data.push(value);
					})
					$("#prRequest").DataTable().row.add([
	            		/* '<input type="checkbox" value="' + data[0] + '">', */
	            		'',
	            		data[0],
	            		data[1],
	            		data[2],
	            		data[3],
	            		data[4],
	            		data[5],
	            		'<a href="#" class="delete"><i class="far fa-trash-alt"></i></a>'
	            	]).draw(); 
					new_item_html();
					
					// 更新主表總額
					var totalPrice = $("#totalPrice").val();
					if(totalPrice!=""){
						totalPrice = parseInt(totalPrice);
					}
					totalPrice += data[2]*data[3];
					/* totalPrice = formatter.format(totalPrice); */  ///轉換為金額格式
					$("#totalPrice").val(totalPrice);
					
					// 更動material的按鈕(這只會刪當前表= =)
					$("#btnAddToRemove").remove();
					// 加入itemsBeAdded陣列
					itemsBeAdded.push(data[0]);
					
					// 刪除追蹤目標
					itemBePending.splice(0,1);
				} 
			})
		}
		
		
		  // 對於品項表的操作
		 function materials_table(){
			$(".item_input").hide();
			let flag = false;
			var table = $("#table_materials").DataTable({
	            data :materials, 
				order: [[ 1, "asc" ]],
				searching: false,  //關閉filter功能
				lengthChange: false,
	            responsive: true,
	            columnDefs: [{
                    targets: [0,2,3,4,5],
                    orderable: false,
	                
	            }, {
	            	targets: [3,4],
	            	render: $.fn.dataTable.render.number(',', '', 0, ''),
	            },{targets: 0,
	                data: null,
	                render: function (data, type, row, meta){
	                	return "<button id='btnRemoveToAdd' class='btn btn-info' data-id='"+parseInt(data[1])+"'><i class='fas fa-plus'></i></button>";
	                },
	               /*  defaultContent: "<button id='btnRemoveToAdd' class='btn btn-info'><i class='fas fa-plus'></i></button>" */
	            }],
				 drawCallback: function( settings ) {
						//1. 如果有追蹤項目時，當表格刷新前要先進行判斷
							 if(itemBePending.length!=0){
								// 當前頁面
							    var nowPage = table.page.info().page+1;
								// itemBePending所在的頁面
								var item = (Math.floor(itemBePending[0]%10)!=0)? Math.floor(itemBePending[0]/10)+1 : Math.floor(itemBePending[0]/10); 
								// 當"非選擇項目頁"時，如果頁面也不對的id刪除還原
								if(item!=nowPage){
									$("#btnAddToRemove").each(function(index, value){
										$(this).attr("id","btnRemoveToAdd");
							        	$(this).removeClass("btn-danger").addClass("btn-info");
							        	$(this).children().removeClass("fa-minus").addClass("fa-plus");
									}) 
								}
						//2. 當刪除主表時，材料表有點選過的話也要刷新
							 }else if(itemBePending.length==0){
								// 當追蹤項目為0但卻有紅色id時，就要移除
								 $("#btnAddToRemove").each(function(index, value){
										$(this).attr("id","btnRemoveToAdd");
							        	$(this).removeClass("btn-danger").addClass("btn-info");
							        	$(this).children().removeClass("fa-minus").addClass("fa-plus");
								}) 
							 }
						// 3. 已加入請購單的項目，按鈕需要刪除
							// 當前頁面
							if(itemsBeAdded.length!=0){
								 var nowPage = table.page.info().page+1;
								 itemsBeAdded.forEach(function(item, idx){
									let itemPage = (Math.floor(item%10)!=0)? Math.floor(item/10)+1 : Math.floor(item/10);
									console.log(item+"在頁:"+itemPage)
									if(itemPage==nowPage){
										$("#btnRemoveToAdd").each(function(){
											console.log($(this).data("id"))
											if($(this).data("id")==item){
												console.log("Wrong")
											}
										})
									}
								 })
							} 
					    }
					});

			
			$('#table_materials tbody').on('click', '[id*=btnRemoveToAdd]', function () {
				// 當有點擊過，要先將被點擊過的按鈕狀態改回來
				if(flag ==true){
					$("#btnAddToRemove").children().removeClass("fa-minus").addClass("fa-plus");
					$("#btnAddToRemove").removeClass("btn-danger").addClass("btn-info");
					$("#btnAddToRemove").attr("id","btnRemoveToAdd");
				}
			
				var nowRow = table.row($(this).parents('tr'));
	        	var data = table.row($(this).parents('tr')).data();
	        	// 全域變數紀錄當前請購單選擇的項目
				itemBePending[0]= data[1]; 
	        	$('.new_item td:nth-of-type(2)').html(data[1]);
	        	$('.new_item td:nth-of-type(3)').html(data[2]);
	        	$('.new_item td:nth-of-type(5)').html(data[3]);
	        	$('.new_item td:nth-of-type(6)').html(data[4]);
	        	$('.new_item td:nth-of-type(7)').html(data[5]);
	        	$('.new_item td:nth-of-type(4)').focus();
	        	
	        	// 更改按鈕狀態
	        	$(this).attr("id","btnAddToRemove");
	        	$(this).removeClass("btn-info").addClass("btn-danger");
	        	$(this).children().removeClass("fa-plus").addClass("fa-minus");
	        	flag = true;
	        });
		
			/* 點擊紅色按鈕(自身) 切換回來*/
			$('#table_materials tbody').on('click', '[id*=btnAddToRemove]', function () {
				// 刪除明細表的資料
				$(".new_item").remove();
				new_item_html();
				// 更改按鈕狀態
				$(this).attr("id","btnRemoveToAdd");
	        	$(this).removeClass("btn-danger").addClass("btn-info");
	        	$(this).children().removeClass("fa-minus").addClass("fa-plus");
	        });
		  
		};
		// end of Function	

		// 刪除細目表的項目
		function delete_Item (fetch_data){
			$("#prRequest").on("click",".delete",function(e){
				e.preventDefault();
				// 刪除明細表的資料
				var nowRow = fetch_data.row($(this).parents('tr'));
            	var data = fetch_data.row($(this).parents('tr')).data();
            	nowRow.remove().draw();
            	
            	var pRequestID = data[1]; 
            	var table = $("#table_materials").DataTable();
            	table.cell(pRequestID-1,0).data("<button id='btnRemoveToAdd' class='btn btn-info'><i class='fas fa-plus'></i></button>").draw();
            	
            	// 刪除總額
            	var totalPrice = $("#totalPrice").val();
				if(totalPrice!=""){
					totalPrice = parseInt(totalPrice);
				}
				totalPrice -= (parseInt(data[3])*parseInt(data[4]));
				$("#totalPrice").val(totalPrice);
				new_item_html();
				
				// 刪除追蹤目標
				itemBePending.splice(0,1);
				// 當追蹤項目為0但卻有紅色id時，就要移除
				 $("#btnAddToRemove").each(function(index, value){
						$(this).attr("id","btnRemoveToAdd");
			        	$(this).removeClass("btn-danger").addClass("btn-info");
			        	$(this).children().removeClass("fa-minus").addClass("fa-plus");
				})
			})	
		}
		
		// 主表 加新增資料列
	    function new_item_html(){
			   var html = '<tr class="new_item">';
			   html += '<td></td>';
			   html += '<td data-col="1"></td>';
			   html += '<td  data-col="2"></td>';
			   html += '<td contenteditable data-col="3"></td>';
			   html += '<td data-col="4"></td>';
			   html += '<td data-col="5"></td>';
			   html += '<td data-col="7" v></td>';
			   html += '<td><a href="#" id="insert" class="text-info mr-1"><i class="fas fa-check"></i></a>';
			   html += '</tr>';
			   $('#prRequest').prepend(html);
		  };
		
		  // 輸入數值驗證
		  function validationInsert(){
				let td4= $('.new_item td:nth-of-type(4)').html();
				if($(".new_item td:nth-of-type(2)").html()==""){
					alert("請從品項表添加項目");
					return false;
				}
				if(td4==""){
					alert("請求數量需填入");
					$('.new_item td:nth-of-type(4)').focus();
					return false;
				}
				if(isNaN(td4)){
					alert("請求數量需為數字");
					return false;
				}
				if(td4<1){
					alert("數量/單價不可小於0");
					return false;
				}
				return true; 
			}
		
		  
		// 時間轉換
		Date.prototype.yyyymmdd = function() {
			var mm = this.getMonth() + 1; // getMonth() is zero-based
			var dd = this.getDate();
			return [ this.getFullYear(), (mm > 9 ? '' : '0') + mm,
					(dd > 9 ? '' : '0') + dd ].join('-');
		};
		
		// 金額的轉換器
		var formatter = new Intl.NumberFormat('en-US', {
			  style: 'currency',
			  currency: 'TWD',
			  minimumFractionDigits: 0,
		});
		
		// 要送出的資料至後端
		(function getSubmitData (){
			$("#to_submit").click(function(){
				// 資料檢查
				var forms = document.getElementsByClassName('needs-validation');
				var table = $('#prRequest').DataTable();
			    // Loop over them and prevent submission
			    var validation = Array.prototype.filter.call(forms, function(form) {
			        if (form.checkValidity() === false) {
			        	 form.classList.add('was-validated');
			        }else if(table.data().length==0){
			        	alert("每筆請購單至少要有一品項");
			        }else{
			        	let new_purchaseRequests = {};
						// 取得上方主檔內容
						$("form input, form textarea").each(function(){
							var input = $(this);
							if(input.attr("name")!= undefined){
								new_purchaseRequests[input.attr("name")] = input.val();
							}
						})
						// 取得dataTable的明細內容
						new_purchaseRequests.purchaseRequestDetails = [];
						// 從頭開始讀起
						table.rows().eq(0).each( function ( index ) {
							//取得每列的資料陣列 
					    	var data = table.row(index).data();
							var detail = {}
							detail["materialsId"] = data[1];
							detail["quantity"] = data[3];
							detail["unitPrice"] = data[4];
							new_purchaseRequests.purchaseRequestDetails.push(detail);
						} );
						if(confirm("確定送出請購單?")){
						 sendData(new_purchaseRequests)
						 }
			        }
			     })
			})
		})();
		
		function sendData(new_purchaseRequests) {
			console.log(new_purchaseRequests);
			$.ajax({
					url : "../insertOnePurchaseRequest2",
					data :  JSON.stringify(new_purchaseRequests),
					contentType : "application/json" ,
					type : "POST"
					}).done(function(){
						loadingPage('/purchase/GetAllPurchaseRequest');
					}).fail(function(){
						alert("新增失敗");
					});
			}
	</script>
</body>
</html>